#!/usr/bin/env ruby
# GitHub Copilot preToolUse hook. The rule lives in .agents/hooks/lib/git_guard.rb.
# Copilot treats a crash or non-zero exit as a deny, so every unexpected input exits 0.
require "json"
require_relative "../../.agents/hooks/lib/git_guard"

begin
  args = JSON.parse($stdin.read)["toolArgs"]
  args = JSON.parse(args) if args.is_a?(String)
  command = args["command"] if args.is_a?(Hash)
  message = GitGuard.violation(command)
rescue StandardError
  exit 0
end

exit 0 unless message

puts JSON.generate(permissionDecision: "deny", permissionDecisionReason: message)
warn message
exit 2
