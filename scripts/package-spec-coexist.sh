#!/usr/bin/env bash
# Package the spec-coexist skill suite as a distributable Claude Code plugin.
#
# Source layout (dev):
#   .claude/skills/*                              (live-reloaded during dev)
#   packaging/spec-coexist/.claude-plugin/plugin.json
#
# Output layout (plugin, per https://code.claude.com/docs/en/plugins):
#   spec-coexist/
#     .claude-plugin/plugin.json
#     skills/<skill-name>/SKILL.md (+ supporting files)
#
# Emits dist/spec-coexist-<version>.tar.gz

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
src_skills="$repo_root/.claude/skills"
src_meta="$repo_root/packaging/spec-coexist/.claude-plugin/plugin.json"
dist_dir="$repo_root/dist"

if [[ ! -f "$src_meta" ]]; then
  echo "error: plugin manifest not found at $src_meta" >&2
  exit 1
fi
if [[ ! -d "$src_skills" ]]; then
  echo "error: skills directory not found at $src_skills" >&2
  exit 1
fi

# Extract version from plugin.json without requiring jq.
version="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$src_meta" | head -n1)"
: "${version:=0.0.0}"

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

plugin_root="$staging/spec-coexist"
mkdir -p "$plugin_root/.claude-plugin" "$plugin_root/skills"

cp "$src_meta" "$plugin_root/.claude-plugin/plugin.json"

# Copy every skill directory (including _shared supporting files).
# Using tar to preserve perms & skip nothing; excludes typical junk.
tar -C "$src_skills" \
  --exclude='.DS_Store' \
  --exclude='__pycache__' \
  -cf - . | tar -C "$plugin_root/skills" -xf -

mkdir -p "$dist_dir"
archive="$dist_dir/spec-coexist-${version}.tar.gz"
tar -C "$staging" -czf "$archive" spec-coexist

echo "built $archive"
echo "contents:"
tar -tzf "$archive" | sed 's/^/  /'
