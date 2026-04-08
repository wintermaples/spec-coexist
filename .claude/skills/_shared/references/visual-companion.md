# Visual Companion (spec-coexist)

A self-contained, browser-based visual brainstorming mode used inside any spec-coexist skill. This is the project-local equivalent of `superpowers:brainstorming`'s `visual-companion.md`.

The server is **a single Python file using only the standard library** (`http.server`) — no third-party dependencies, no licensing concerns. Everything ships under `_shared/scripts/`.

## When to Launch

Decide per question, not per session. The test: **would the user understand this question better by seeing it than by reading words?**

**Launch the Visual Companion when** the question is fundamentally visual:

- UI mockups — wireframes, layouts, navigation
- Architecture diagrams — components, data flow, relationships
- Side-by-side comparisons — two layouts, two screen flows
- State machines / flowcharts where shape matters
- Spatial relationships — anything where position is the answer

**Stay in plain terminal Q&A when** the question is conceptual: scope, A/B/C wording choices, API design, tradeoffs, clarifications.

A question *about* a UI topic is not automatically visual. "What kind of dashboard do you want?" is conceptual. "Which of these dashboard layouts feels right?" is visual.

## Consent

You **MUST** request consent to launch the Visual Companion exactly once, in its own standalone message — no other questions in the same message. Example:

> I'd like to switch into Visual Companion mode for the next few questions because they're about screen layout. Is that okay? (yes / no)

If the user declines, continue brainstorming in plain terminal mode.

## Starting the Server

```bash
.claude/skills/_shared/scripts/start_visual_server.sh <project-dir> [--host 0.0.0.0] [--port 0] [--url-host localhost]
```

The wrapper backgrounds `visual_server.py` and prints three lines to stdout:

```
{"type":"server-started","port":52341,"url":"http://127.0.0.1:52341",
 "screen_dir":"<project>/.spec-coexist/visual/<session>/content",
 "state_dir":"<project>/.spec-coexist/visual/<session>/state"}
pid=12345
log=/tmp/spec-coexist-visual.XXXXXX.log
```

You **MUST** capture and remember `screen_dir`, `state_dir`, `url`, and `pid`.

Tell the user the URL and ask them to open it in a browser. Add `.spec-coexist/` to `.gitignore` if it's not already there.

**Host binding:** the server binds to `0.0.0.0` by default so devcontainers and remote environments work out of the box, and the printed URL uses `localhost`. Pass `--host 127.0.0.1` if you need loopback-only binding.

The server exits automatically after **30 minutes of inactivity** and writes a `state_dir/server-stopped` marker. If you see that marker, restart the server before pushing new content.

## The Loop

1. **Verify the server is alive.** Check that `state_dir/server-info` exists and `state_dir/server-stopped` does **not** exist. If stopped, restart.
2. **Write a content file** to `screen_dir`:
   - Use semantic filenames: `layout.html`, `header.html`, `auth-flow.html`.
   - **Never reuse filenames.** Each screen is a fresh file. For iterations, append `-v2`, `-v3`.
   - Use the Write tool. Do **not** use `cat`/heredoc — that dumps noise into the terminal.
   - The server serves the newest file by mtime automatically and the browser auto-reloads via polling.
3. **Tell the user what's on screen and end your turn.** Restate the URL each time. Give a one-sentence summary ("Showing 3 header layouts"). Ask them to reply in the terminal and/or click an option.
4. **On your next turn**, read `state_dir/events` (one JSON object per line) for browser interactions, plus the user's terminal text. The terminal text is primary; events provide structured click data.
5. **Iterate or advance.** If feedback changes the current screen, write a new versioned file. Only move on when the current question is settled.
6. **Unload before returning to terminal mode.** When the next question is conceptual, push a `waiting.html`:
   ```html
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Continuing in terminal…</p>
   </div>
   ```
   Then explicitly tell the user: "Switching back to text Q&A for the next question."
7. **Stop the server when done:**
   ```bash
   .claude/skills/_shared/scripts/stop_visual_server.sh <pid>
   ```

## Content Fragments vs Full Documents

If your HTML file starts with `<!doctype` or `<html`, the server serves it as-is (only the auto-reload poller is implicit via the frame). Otherwise, the server wraps your content in the frame template — header, theme CSS, selection indicator, polling client, all included.

**Write content fragments by default.** Only write a full document when you need complete control over the page.

## CSS Classes Provided by the Frame

### Options (A/B/C choices)

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div><h3>Title</h3><p>Description</p></div>
  </div>
</div>
```

Add `data-multiselect` to `.options` to allow multiple selections.

### Cards (visual designs)

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- mockup --></div>
    <div class="card-body"><h3>Name</h3><p>Description</p></div>
  </div>
</div>
```

### Mockup container & split view

```html
<div class="mockup">
  <div class="mockup-header">Preview: Dashboard</div>
  <div class="mockup-body"><!-- content --></div>
</div>

<div class="split">
  <div class="mockup">…left…</div>
  <div class="mockup">…right…</div>
</div>
```

### Pros/Cons, mock elements, typography

```html
<div class="pros-cons">
  <div class="pros"><h4>Pros</h4><ul><li>…</li></ul></div>
  <div class="cons"><h4>Cons</h4><ul><li>…</li></ul></div>
</div>

<div class="mock-nav">Logo | Home | About</div>
<div class="mock-sidebar">Nav</div>
<div class="mock-content">Main</div>
<button class="mock-button">Action</button>
<input class="mock-input" placeholder="…">
<div class="placeholder">Placeholder area</div>
```

`h2` = page title, `h3` = section heading, `.subtitle` = secondary text, `.label` = small uppercase label.

## Browser Events Format

Clicks are appended as JSONL to `state_dir/events`:

```jsonl
{"type":"click","choice":"a","text":"Single Column — Clean focused …","timestamp":1706000101}
{"type":"click","choice":"b","text":"Two Column — Sidebar nav","timestamp":1706000115}
```

The full stream shows the user's exploration path. The last `choice` is typically the final selection, but multiple clicks may signal hesitation worth probing. If the file does not exist, the user did not click — use only their terminal text.

## Design Tips

- **Scale fidelity to the question.** Wireframes for layout, polish only for polish questions.
- **Restate the question on every screen.** "Which layout feels more compact?" beats "Pick one."
- **2–4 options per screen.** More overwhelms.
- **Iterate by versioning**, not overwriting. Users may want to compare A vs A-v2.
- **One question per screen** — matches the brainstorming "one question per message" rule.

## Files

- `_shared/scripts/visual_server.py` — single-file stdlib HTTP server (Python 3.10+).
- `_shared/scripts/start_visual_server.sh` — backgrounded launcher; emits `server-started` JSON, `pid=…`, `log=…`.
- `_shared/scripts/stop_visual_server.sh` — `kill <pid>`.

No third-party Python packages are required. The server uses only `http.server`, `threading`, `json`, `pathlib`, and friends from the standard library, so there are no licensing concerns.
