#!/usr/bin/env bash
# PostToolUse hook (Edit|Write): autocorrect and lint the file Claude just changed, feeding any
# remaining offences back to Claude (exit 2) so it fixes them. Works on the host and in the devcontainer.
set -uo pipefail

file=$(ruby -rjson -e 'puts JSON.parse($stdin.read).dig("tool_input", "file_path").to_s' 2>/dev/null) || exit 0
[[ -n "$file" && -f "$file" ]] || exit 0
command -v bundle >/dev/null && bundle check >/dev/null 2>&1 || exit 0

case "$file" in
  *.rb | *.rake | */Gemfile) output=$(bundle exec rubocop --autocorrect --force-exclusion --format simple "$file" 2>&1) ;;
  *.slim) output=$(bundle exec slim-lint "$file" 2>&1) ;;
  *) exit 0 ;;
esac

if [[ $? -ne 0 ]]; then
  echo "Lint offences remain in $file:" >&2
  echo "$output" >&2
  exit 2
fi
