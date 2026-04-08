#!/usr/bin/env python3
"""
spec-coexist Visual Companion server.

Self-contained, single-file HTTP server using only the Python standard library.
No third-party dependencies — no license concerns.

Usage:
    python3 visual_server.py --project-dir /path/to/project [--host 127.0.0.1] [--port 0]

On startup, prints a single line of JSON to stdout:
    {"type":"server-started","port":52341,"url":"http://127.0.0.1:52341",
     "screen_dir":"<project>/.spec-coexist/visual/<session>/content",
     "state_dir":"<project>/.spec-coexist/visual/<session>/state"}

The server:
  - Serves the newest *.html file in screen_dir at GET /
  - Wraps content fragments (no <html>) in a frame template with theme CSS
  - Accepts POST /click with JSON {choice, text} and appends to state_dir/events
  - Auto-exits after 30 minutes of no requests
  - Writes server-info / server-stopped marker files for resilience
"""

from __future__ import annotations

import argparse
import datetime as _dt
import json
import os
import sys
import threading
import time
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

INACTIVITY_TIMEOUT_SEC = 30 * 60

FRAME_TEMPLATE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>spec-coexist Visual Companion</title>
<style>
  :root {
    --bg: #0f1115; --panel: #161922; --fg: #e6e8ef; --muted: #8a90a2;
    --accent: #6aa0ff; --accent-soft: #1f2a44; --border: #242838;
    --good: #59d29b; --warn: #f1c40f;
  }
  * { box-sizing: border-box; }
  html, body { margin: 0; padding: 0; background: var(--bg); color: var(--fg);
    font: 15px/1.5 -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif; }
  header { padding: 14px 22px; border-bottom: 1px solid var(--border);
    display: flex; align-items: center; justify-content: space-between; background: var(--panel); }
  header .title { font-weight: 600; letter-spacing: .02em; }
  header .indicator { font-size: 13px; color: var(--muted); }
  main { max-width: 960px; margin: 0 auto; padding: 28px 22px 60px; }
  h2 { margin: 0 0 6px; font-size: 22px; }
  h3 { margin: 0 0 4px; font-size: 17px; }
  .subtitle { color: var(--muted); margin: 0 0 22px; }
  .options, .cards { display: grid; gap: 14px; }
  .options { grid-template-columns: 1fr; }
  .cards { grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); }
  .option, .card { background: var(--panel); border: 1px solid var(--border);
    border-radius: 10px; padding: 16px 18px; cursor: pointer; transition: all .12s ease;
    display: flex; gap: 14px; align-items: flex-start; }
  .option:hover, .card:hover { border-color: var(--accent); transform: translateY(-1px); }
  .option.selected, .card.selected { border-color: var(--accent);
    background: var(--accent-soft); box-shadow: 0 0 0 2px var(--accent) inset; }
  .letter { width: 28px; height: 28px; border-radius: 50%; background: var(--accent-soft);
    color: var(--accent); display: flex; align-items: center; justify-content: center;
    font-weight: 700; flex: 0 0 28px; }
  .mockup { background: #fff; color: #222; border-radius: 8px; overflow: hidden;
    border: 1px solid var(--border); }
  .mockup-header { background: #eee; padding: 6px 10px; font-size: 12px; color: #666; }
  .mockup-body { padding: 14px; font-family: ui-monospace, Menlo, Consolas, monospace;
    white-space: pre-wrap; }
  .split { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
  .pros-cons { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-top: 12px; }
  .pros, .cons { background: var(--panel); border: 1px solid var(--border);
    border-radius: 8px; padding: 12px 16px; }
  .pros h4 { color: var(--good); margin: 0 0 6px; }
  .cons h4 { color: var(--warn); margin: 0 0 6px; }
  .label { text-transform: uppercase; letter-spacing: .08em; font-size: 11px; color: var(--muted); }
  .mock-nav, .mock-sidebar, .mock-content { background: #2a2f42; padding: 8px 12px;
    border-radius: 6px; margin: 4px 0; }
  .mock-button { background: var(--accent); color: #fff; border: 0; padding: 6px 14px;
    border-radius: 6px; cursor: pointer; }
  .mock-input { background: #1c2032; border: 1px solid var(--border); color: var(--fg);
    padding: 6px 10px; border-radius: 6px; }
  .placeholder { background: #1c2032; border: 1px dashed var(--border); padding: 18px;
    text-align: center; color: var(--muted); border-radius: 8px; }
  pre { background: #0b0d14; border: 1px solid var(--border); border-radius: 8px;
    padding: 12px 14px; overflow-x: auto; }
</style>
</head>
<body>
<header>
  <div class="title">spec-coexist · Visual Companion</div>
  <div class="indicator" id="indicator">no selection</div>
</header>
<main id="content">__CONTENT__</main>
<script>
function toggleSelect(el) {
  const container = el.closest('.options, .cards');
  const multi = container && container.hasAttribute('data-multiselect');
  if (!multi) {
    container.querySelectorAll('.selected').forEach(e => e.classList.remove('selected'));
  }
  el.classList.toggle('selected');
  const choice = el.getAttribute('data-choice') || '';
  const text = (el.innerText || '').trim().replace(/\\s+/g, ' ').slice(0, 200);
  fetch('/click', { method: 'POST', headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({ choice, text }) }).catch(() => {});
  const sel = container.querySelectorAll('.selected');
  document.getElementById('indicator').textContent =
    sel.length === 0 ? 'no selection' :
    sel.length === 1 ? 'selected: ' + (sel[0].getAttribute('data-choice') || '?') :
    sel.length + ' selected';
}
let lastMtime = 0;
async function poll() {
  try {
    const r = await fetch('/_poll');
    if (r.ok) {
      const j = await r.json();
      if (j.mtime && j.mtime !== lastMtime) {
        if (lastMtime !== 0) location.reload();
        lastMtime = j.mtime;
      }
    }
  } catch (e) {}
  setTimeout(poll, 1500);
}
poll();
</script>
</body>
</html>
"""


class State:
    def __init__(self, screen_dir: Path, state_dir: Path):
        self.screen_dir = screen_dir
        self.state_dir = state_dir
        self.last_request = time.time()
        self.lock = threading.Lock()

    def newest_html(self) -> Path | None:
        files = sorted(self.screen_dir.glob("*.html"), key=lambda p: p.stat().st_mtime)
        return files[-1] if files else None

    def render_page(self) -> bytes:
        f = self.newest_html()
        if not f:
            body = ('<h2>Waiting for content…</h2>'
                    '<p class="subtitle">No HTML files in screen_dir yet. '
                    'Write a *.html file to display it here.</p>')
            return FRAME_TEMPLATE.replace("__CONTENT__", body).encode("utf-8")
        raw = f.read_text(encoding="utf-8", errors="replace")
        head = raw.lstrip()[:32].lower()
        if head.startswith("<!doctype") or head.startswith("<html"):
            return raw.encode("utf-8")
        return FRAME_TEMPLATE.replace("__CONTENT__", raw).encode("utf-8")

    def newest_mtime(self) -> float:
        f = self.newest_html()
        return f.stat().st_mtime if f else 0.0

    def append_event(self, event: dict) -> None:
        event["timestamp"] = int(time.time())
        with self.lock:
            with (self.state_dir / "events").open("a", encoding="utf-8") as fh:
                fh.write(json.dumps(event, ensure_ascii=False) + "\n")


def make_handler(state: State):
    class Handler(BaseHTTPRequestHandler):
        def log_message(self, fmt, *args):
            pass  # silence default access logging

        def _send(self, status: int, body: bytes, ctype: str = "text/html; charset=utf-8"):
            self.send_response(status)
            self.send_header("Content-Type", ctype)
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(body)

        def do_GET(self):
            state.last_request = time.time()
            if self.path == "/" or self.path.startswith("/?"):
                self._send(HTTPStatus.OK, state.render_page())
            elif self.path == "/_poll":
                payload = json.dumps({"mtime": state.newest_mtime()}).encode("utf-8")
                self._send(HTTPStatus.OK, payload, "application/json")
            else:
                self._send(HTTPStatus.NOT_FOUND, b"not found", "text/plain")

        def do_POST(self):
            state.last_request = time.time()
            if self.path != "/click":
                self._send(HTTPStatus.NOT_FOUND, b"not found", "text/plain")
                return
            length = int(self.headers.get("Content-Length", "0") or 0)
            raw = self.rfile.read(length) if length else b"{}"
            try:
                data = json.loads(raw.decode("utf-8") or "{}")
            except json.JSONDecodeError:
                data = {}
            event = {"type": "click",
                     "choice": str(data.get("choice", ""))[:64],
                     "text": str(data.get("text", ""))[:300]}
            state.append_event(event)
            self._send(HTTPStatus.OK, b'{"ok":true}', "application/json")

    return Handler


def inactivity_watchdog(state: State, server: ThreadingHTTPServer, marker: Path):
    while True:
        time.sleep(30)
        if time.time() - state.last_request > INACTIVITY_TIMEOUT_SEC:
            marker.write_text("inactivity timeout\n", encoding="utf-8")
            server.shutdown()
            return


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--project-dir", required=True)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--url-host", default=None,
                    help="Hostname to print in the URL (defaults to --host)")
    ap.add_argument("--port", type=int, default=0)
    args = ap.parse_args()

    project = Path(args.project_dir).resolve()
    ts = _dt.datetime.now().strftime("%y%m%d%H%M%S")
    session = project / ".spec-coexist" / "visual" / f"{os.getpid()}-{ts}"
    screen_dir = session / "content"
    state_dir = session / "state"
    screen_dir.mkdir(parents=True, exist_ok=True)
    state_dir.mkdir(parents=True, exist_ok=True)

    state = State(screen_dir, state_dir)
    server = ThreadingHTTPServer((args.host, args.port), make_handler(state))
    actual_port = server.server_address[1]
    url_host = args.url_host or args.host
    info = {"type": "server-started", "port": actual_port,
            "url": f"http://{url_host}:{actual_port}",
            "screen_dir": str(screen_dir), "state_dir": str(state_dir)}
    (state_dir / "server-info").write_text(json.dumps(info), encoding="utf-8")
    print(json.dumps(info), flush=True)

    marker = state_dir / "server-stopped"
    t = threading.Thread(target=inactivity_watchdog, args=(state, server, marker), daemon=True)
    t.start()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        if not marker.exists():
            marker.write_text("shutdown\n", encoding="utf-8")
        server.server_close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
