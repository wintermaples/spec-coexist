#!/usr/bin/env python3
"""run.py — cross-platform wrapper for _shared/scripts/*.sh helpers.

Usage:
    python run.py <script-name> [args...]

Resolves `<script-name>.sh` inside the directory containing this file and
invokes it, translating the call to something that works on macOS, Linux,
and Windows (PowerShell / cmd).

Why this exists
---------------
Every helper in `_shared/scripts/` is authored as a POSIX shell script.
That is fine on macOS and Linux, but stock Windows does not ship a bash
interpreter. Skills that invoke scripts via this wrapper stay portable:
the wrapper picks a working shell in this order:

    1. `bash` on PATH                 (macOS, Linux, Git Bash, WSL)
    2. `sh` on PATH                   (minimal POSIX fallback)
    3. `wsl bash`                     (Windows with WSL installed)
    4. `C:\\Program Files\\Git\\bin\\bash.exe` (Windows with Git for Windows)

If none of the above resolve, the wrapper exits with code 127 and prints
a single-line remediation hint. It does not attempt to emulate bash in
pure Python; the scripts themselves stay canonical.

Exit codes
----------
The wrapper passes through the wrapped script's exit code. Its own
failures use 64 (usage), 66 (script not found), 127 (no shell).
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent


def find_shell() -> list[str] | None:
    """Return an argv prefix for a working POSIX shell, or None."""
    for candidate in ("bash", "sh"):
        path = shutil.which(candidate)
        if path:
            return [path]

    if os.name == "nt":
        wsl = shutil.which("wsl")
        if wsl:
            return [wsl, "bash"]

        git_bash = Path(r"C:\Program Files\Git\bin\bash.exe")
        if git_bash.exists():
            return [str(git_bash)]

    return None


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: run.py <script-name> [args...]", file=sys.stderr)
        return 64

    name = argv[1]
    rest = argv[2:]

    script_path = SCRIPT_DIR / f"{name}.sh"
    if not script_path.exists():
        print(f"run.py: script not found: {script_path}", file=sys.stderr)
        return 66

    shell = find_shell()
    if shell is None:
        print(
            "run.py: no POSIX shell found. Install Git for Windows or WSL, "
            "or run the .sh script directly from a bash-capable terminal.",
            file=sys.stderr,
        )
        return 127

    cmd = shell + [str(script_path), *rest]
    completed = subprocess.run(cmd)
    return completed.returncode


if __name__ == "__main__":
    sys.exit(main(sys.argv))
