#!/usr/bin/env ruby
# Claude Code PostToolUse hook (Edit|Write). The rule lives in .agents/hooks/lib/file_linter.rb.
# Exit 2 feeds the remaining offences back to Claude so it fixes them.
require "json"
require_relative "../../.agents/hooks/lib/file_linter"

begin
  path = JSON.parse($stdin.read).dig("tool_input", "file_path")
rescue StandardError
  exit 0
end

if (output = FileLinter.offences(path))
  warn "Lint offences remain in #{path}:"
  warn output
  exit 2
end
