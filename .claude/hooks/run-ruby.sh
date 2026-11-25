#!/bin/sh
# Runs a Ruby hook script with the Ruby pinned in .ruby-version. Used by every hook in .claude/settings.json.
# Usage: run-ruby.sh <path/to/hook.rb>
# Agent apps launched from the Dock get a bare PATH, where `ruby` may be a shim for another version manager or
# the system Ruby, so the pinned version is also looked for where mise, rbenv, asdf and chruby install it.
# Its bin directory goes first on PATH so `bundle` matches. Without it the hook blocks (exit 2), so a missing Ruby
# never turns the guards off. Otherwise only the hook's exit code 2 (an intentional block, or lint feedback for
# Claude Code) is propagated, with its stdout and stderr; any other failure exits 0, as Copilot denies on non-zero.
root=$(cd "$(dirname "$0")/../.." && pwd)
version=$(tr -d '[:space:]' < "$root/.ruby-version")
input=$(cat)

for candidate in ruby \
  "$HOME/.local/share/mise/installs/ruby/$version/bin/ruby" \
  "$HOME/.rbenv/versions/$version/bin/ruby" \
  "$HOME/.asdf/installs/ruby/$version/bin/ruby" \
  "$HOME/.rubies/ruby-$version/bin/ruby" \
  "/opt/rubies/ruby-$version/bin/ruby"; do
  bindir=$("$candidate" -e "print RUBY_VERSION != '$version' ? '' : RbConfig::CONFIG['bindir']" 2>/dev/null)
  [ -n "$bindir" ] || continue
  printf %s "$input" | PATH="$bindir:$PATH" "$bindir/ruby" "$1"
  [ "$?" -eq 2 ] && exit 2
  exit 0
done

# No pinned Ruby: fail closed, so the guards can't be bypassed by a missing Ruby
message="Blocked: hook $(basename "$1") needs Ruby $version (.ruby-version), which is not installed. Install it with your version manager (e.g. mise install)."
printf '{"permissionDecision":"deny","permissionDecisionReason":"%s"}\n' "$message"
echo "$message" >&2
exit 2
