#!/usr/bin/env ruby
# Claude Code PreToolUse hook (Bash). The rule lives in .agents/hooks/lib/git_guard.rb.
# Exit 2 blocks the command and shows the message to Claude; anything unparseable is let through.
require "json"
require_relative "../../.agents/hooks/lib/git_guard"

begin
  command = JSON.parse($stdin.read).dig("tool_input", "command")
rescue StandardError
  exit 0
end

if (message = GitGuard.violation(command))
  warn message
  exit 2
end
