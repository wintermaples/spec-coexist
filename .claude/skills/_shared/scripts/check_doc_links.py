#!/usr/bin/env python3
"""check_doc_links.py — spec-coexist document reference/link integrity checker.

Walks a docs tree, parses YAML-ish frontmatter and Markdown links, and reports
broken references, bad anchors, lifecycle violations, and extends-cycles.

Scope: uses the Python standard library only. The "YAML" parser is a tiny
subset sufficient for the frontmatter schema defined in
`.claude/skills/_shared/references/doc-reference-syntax.md` — it supports
scalars and flat lists of strings. It is NOT a general YAML parser.

Usage:
    python check_doc_links.py [--root docs] [--strict] [--json]

Exit codes:
    0  no errors (warnings allowed unless --strict)
    1  errors found (or warnings with --strict)
    2  usage / IO failure
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)
# Markdown link: [text](target)
MD_LINK_RE = re.compile(r"\[([^\]]*)\]\(([^)]+)\)")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*?)\s*$", re.MULTILINE)

LIFECYCLE_ACTIVE = {"active", "draft"}
LIFECYCLE_RETIRED = {"deprecated", "superseded"}
LIFECYCLE_ALL = LIFECYCLE_ACTIVE | LIFECYCLE_RETIRED

REQ_ID_RE = re.compile(r"REQ-[A-Z0-9_]+-[0-9]+")
# Default: warn if a draft doc has not been updated for this many days
STALE_DRAFT_DAYS = 30


@dataclass
class Finding:
    kind: str  # MISSING | BAD_ANCHOR | LIFECYCLE_INVALID | CYCLE | FRONTMATTER
    level: str  # error | warning
    file: str
    detail: str
    target: str = ""


@dataclass
class DocMeta:
    path: Path
    status: str = ""
    extends: list[str] = field(default_factory=list)
    supersedes: list[str] = field(default_factory=list)
    superseded_by: list[str] = field(default_factory=list)
    related: list[str] = field(default_factory=list)
    headings: set[str] = field(default_factory=set)


def slugify(text: str) -> str:
    """GitHub-style heading slug."""
    text = text.strip().lower()
    text = re.sub(r"[^\w\s-]", "", text, flags=re.UNICODE)
    text = re.sub(r"\s+", "-", text)
    return text.strip("-")


def parse_frontmatter(text: str) -> tuple[dict, str]:
    """Return (frontmatter-dict, body) for a doc. Empty dict if none."""
    m = FRONTMATTER_RE.match(text)
    if not m:
        return {}, text
    raw = m.group(1)
    data: dict = {}
    current_key: str | None = None
    for raw_line in raw.splitlines():
        line = raw_line.rstrip()
        if not line or line.lstrip().startswith("#"):
            continue
        if line.startswith(("  - ", "- ")):
            item = line.split("-", 1)[1].strip().strip("'\"")
            if current_key is None:
                continue
            if item and item.lower() != "null":
                data.setdefault(current_key, []).append(item)
            continue
        if ":" in line:
            key, _, value = line.partition(":")
            key = key.strip()
            value = value.strip().strip("'\"")
            current_key = key
            if value == "":
                data.setdefault(key, [])
            else:
                data[key] = value
    body = text[m.end():]
    return data, body


def extract_headings(body: str) -> set[str]:
    return {slugify(h[1]) for h in HEADING_RE.findall(body)}


def extract_links(body: str) -> list[tuple[str, str]]:
    """Return list of (path, anchor) tuples for local .md links only."""
    out: list[tuple[str, str]] = []
    for _text, target in MD_LINK_RE.findall(body):
        target = target.strip()
        if not target or target.startswith(("http://", "https://", "mailto:", "#")):
            continue
        # Strip title: [x](foo.md "title")
        target = target.split(" ", 1)[0]
        path, _, anchor = target.partition("#")
        if not path.endswith(".md"):
            continue
        out.append((path, anchor))
    return out


def load_doc(path: Path) -> DocMeta:
    text = path.read_text(encoding="utf-8")
    fm, body = parse_frontmatter(text)
    meta = DocMeta(path=path)
    meta.status = str(fm.get("status", "")).strip()
    for key in ("extends", "supersedes", "superseded_by", "related"):
        val = fm.get(key, [])
        if isinstance(val, list):
            meta.__setattr__(key, [str(v) for v in val if v])
        elif isinstance(val, str) and val:
            meta.__setattr__(key, [val])
    meta.headings = extract_headings(body)
    return meta


def resolve(src: Path, ref: str, root: Path) -> Path:
    """Resolve ref (with optional #anchor already stripped) relative to src file."""
    target = ref.strip()
    if target.startswith("/"):
        return (root / target.lstrip("/")).resolve()
    return (src.parent / target).resolve()


def is_template_file(p: Path) -> bool:
    """Skeleton/template files under docs/ are not production specs — they
    carry placeholder links (e.g. `subsystem-A/...`) that intentionally do not
    resolve. Match filenames ending in `-template.md` or `-template-rules.md`."""
    name = p.name
    return name.endswith("-template.md") or name.endswith("-template-rules.md")


def check(root: Path, strict: bool, stale_days: int = STALE_DRAFT_DAYS) -> list[Finding]:
    findings: list[Finding] = []
    md_files = [p for p in sorted(root.rglob("*.md")) if not is_template_file(p)]
    docs: dict[Path, DocMeta] = {}

    for p in md_files:
        try:
            docs[p.resolve()] = load_doc(p)
        except Exception as e:
            findings.append(Finding("FRONTMATTER", "error", str(p), f"parse failed: {e}"))

    # Body link + frontmatter ref checks
    for src, meta in docs.items():
        text = src.read_text(encoding="utf-8")
        _, body = parse_frontmatter(text)

        def check_ref(ref: str, kind_label: str, has_anchor: bool = True) -> None:
            if not ref:
                return
            path_part, _, anchor = ref.partition("#") if has_anchor else (ref, "", "")
            if not path_part.endswith(".md"):
                return
            target = resolve(src, path_part, root)
            if not target.exists():
                findings.append(
                    Finding("MISSING", "error", str(src), f"{kind_label} -> {ref}", str(target))
                )
                return
            if anchor:
                t_meta = docs.get(target)
                if t_meta and anchor not in t_meta.headings:
                    findings.append(
                        Finding(
                            "BAD_ANCHOR", "error", str(src),
                            f"{kind_label} -> {ref} (anchor '{anchor}' not in target)",
                            str(target),
                        )
                    )

        for path, anchor in extract_links(body):
            check_ref(f"{path}#{anchor}" if anchor else path, "body-link")

        for key in ("extends", "supersedes", "superseded_by", "related"):
            for ref in getattr(meta, key):
                check_ref(ref, f"frontmatter:{key}")

        # Lifecycle sanity
        if meta.status and meta.status not in LIFECYCLE_ALL:
            findings.append(
                Finding("LIFECYCLE_INVALID", "error", str(src),
                        f"unknown status '{meta.status}' (expected one of {sorted(LIFECYCLE_ALL)})")
            )
        if meta.status in LIFECYCLE_RETIRED and not meta.superseded_by:
            findings.append(
                Finding("LIFECYCLE_INVALID", "error", str(src),
                        f"status '{meta.status}' requires non-empty superseded_by")
            )
        for ref in meta.supersedes:
            path_part = ref.partition("#")[0]
            target = resolve(src, path_part, root)
            t_meta = docs.get(target)
            if t_meta and t_meta.status and t_meta.status not in LIFECYCLE_RETIRED:
                findings.append(
                    Finding("LIFECYCLE_INVALID", "warning", str(src),
                            f"supersedes target still has status '{t_meta.status}' "
                            f"(expected deprecated/superseded)", str(target))
                )

    # ─── Active REQ-ID evidence verification ───
    # For each doc with status=active, check that every REQ-ID has at least one
    # verification-result evidence in .spec-coexist/evidence/.
    evidence_dir = root.parent / ".spec-coexist" / "evidence"
    evidence_req_ids: set[str] = set()
    if evidence_dir.is_dir():
        for ev_file in evidence_dir.rglob("*.json"):
            try:
                ev_data = json.loads(ev_file.read_text(encoding="utf-8"))
                if ev_data.get("proof_type") == "verification-result" and ev_data.get("result") == "pass":
                    # Collect REQ-IDs referenced in the evidence subject or body
                    ev_text = ev_file.read_text(encoding="utf-8")
                    evidence_req_ids.update(REQ_ID_RE.findall(ev_text))
            except Exception:
                pass

    for src, meta in docs.items():
        if meta.status != "active":
            continue
        text = src.read_text(encoding="utf-8")
        req_ids_in_doc = set(REQ_ID_RE.findall(text))
        for req_id in sorted(req_ids_in_doc):
            if req_id not in evidence_req_ids:
                findings.append(
                    Finding(
                        "EVIDENCE_MISSING", "warning", str(src),
                        f"active REQ-ID {req_id} has no passing verification-result evidence"
                    )
                )

    # ─── Stale draft detection ───
    # Warn if a draft document has not been modified for STALE_DRAFT_DAYS.
    for src, meta in docs.items():
        if meta.status != "draft":
            continue
        try:
            # Use git log to find the last modification date
            result = subprocess.run(
                ["git", "log", "-1", "--format=%aI", "--", str(src)],
                capture_output=True, text=True, timeout=10
            )
            if result.returncode == 0 and result.stdout.strip():
                last_modified_str = result.stdout.strip()
                # Parse ISO 8601 date
                last_modified = datetime.fromisoformat(last_modified_str)
                now = datetime.now(timezone.utc)
                age_days = (now - last_modified).days
                if age_days > stale_days:
                    findings.append(
                        Finding(
                            "STALE_DRAFT", "warning", str(src),
                            f"draft document unchanged for {age_days} days "
                            f"(threshold: {stale_days} days)"
                        )
                    )
        except (subprocess.TimeoutExpired, FileNotFoundError, ValueError):
            # git not available or parse error — skip silently
            pass

    # Cycle detection on extends graph
    def extends_targets(m: DocMeta) -> list[Path]:
        out = []
        for ref in m.extends:
            path_part = ref.partition("#")[0]
            out.append(resolve(m.path, path_part, root))
        return out

    WHITE, GRAY, BLACK = 0, 1, 2
    color: dict[Path, int] = {p: WHITE for p in docs}

    def visit(node: Path, stack: list[Path]) -> None:
        color[node] = GRAY
        meta = docs.get(node)
        if meta:
            for nxt in extends_targets(meta):
                if nxt not in docs:
                    continue
                if color[nxt] == GRAY:
                    cycle = " -> ".join(str(p) for p in stack + [nxt])
                    findings.append(
                        Finding("CYCLE", "error", str(node), f"extends cycle: {cycle}")
                    )
                elif color[nxt] == WHITE:
                    visit(nxt, stack + [nxt])
        color[node] = BLACK

    for p in docs:
        if color[p] == WHITE:
            visit(p, [p])

    if strict:
        for f in findings:
            if f.level == "warning":
                f.level = "error"

    return findings


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description="spec-coexist doc link checker")
    ap.add_argument("--root", default="docs", help="root directory to scan (default: docs)")
    ap.add_argument("--strict", action="store_true", help="treat warnings as errors")
    ap.add_argument("--json", action="store_true", help="emit JSON report")
    ap.add_argument("--stale-days", type=int, default=STALE_DRAFT_DAYS,
                     help=f"days before a draft is considered stale (default: {STALE_DRAFT_DAYS})")
    args = ap.parse_args(argv)

    root = Path(args.root).resolve()
    if not root.exists():
        print(f"check_doc_links: root not found: {root}", file=sys.stderr)
        return 2
    if not root.is_dir():
        print(f"check_doc_links: root not a directory: {root}", file=sys.stderr)
        return 2

    findings = check(root, args.strict, stale_days=args.stale_days)
    errors = [f for f in findings if f.level == "error"]
    warnings = [f for f in findings if f.level == "warning"]
    files_scanned = sum(1 for _ in root.rglob("*.md"))

    if args.json:
        print(json.dumps({
            "root": str(root),
            "files_scanned": files_scanned,
            "errors": [asdict(f) for f in errors],
            "warnings": [asdict(f) for f in warnings],
        }, indent=2))
    else:
        for f in findings:
            print(f"[{f.level.upper()}] {f.kind}: {f.file}: {f.detail}")
        print(f"scanned {files_scanned} file(s); {len(errors)} error(s), {len(warnings)} warning(s)")

    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
