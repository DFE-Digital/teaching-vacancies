#!/usr/bin/env ruby
# PreToolUse hook for shell commands: blocks `git add -f` and `git commit --no-verify` (AGENTS.md non-negotiables).
# Claude Code runs it from .claude/settings.json (matcher Bash); GitHub Copilot (CLI and app) runs it from
# .github/hooks/agent-hooks.json. It checks no tool name: it only acts on a `command` argument, so an unknown
# Copilot shell tool name can't let a command through.
require "json"
require "shellwords"

module GitGuard
  OPERATORS = %w[; && || | &].freeze

  # Returns the reason the command must be blocked, or nil if it may run. Unparseable commands are let through.
  def self.violation(command)
    # Pad operators so "a|git add -f" splits; padding inside quotes only alters message text
    tokens = command.to_s.gsub(/(\|\||&&|[;|&])/, ' \1 ').shellsplit
    tokens.slice_when { |_, b| OPERATORS.include?(b) }.each do |words|
      message = check_segment(words.drop_while { |w| OPERATORS.include?(w) })
      return message if message
    end
    nil
  rescue ArgumentError
    nil
  end

  def self.check_segment(words)
    index = words.index("git") or return
    args = words.drop(index + 1)
    args = args.drop(2) while %w[-C -c].include?(args.first)
    args = args.drop(1) while args.first&.start_with?("-")
    subcommand, *rest = args

    case subcommand
    when "add" then "Blocked: never force-add gitignored files. If git add refuses, that is the control working (AGENTS.md)." if force_add?(rest)
    when "commit" then "Blocked: do not skip the git-secrets commit hooks with --no-verify." if no_verify?(rest)
    end
  end

  def self.force_add?(args)
    args.include?("--force") || args.any? { |w| short_flags(w, "").include?("f") }
  end

  def self.no_verify?(args)
    args.include?("--no-verify") || args.any? { |w| short_flags(w, "mFcCt").include?("n") }
  end

  # Flags in a short-option cluster such as "-nm"; characters after an option that takes an argument are that argument
  def self.short_flags(word, arg_chars)
    return [] unless word.match?(/\A-[a-zA-Z]/)

    word[1..].chars.slice_after { |c| arg_chars.include?(c) }.first
  end
end

# Shell commands in any input shape seen so far: Claude's tool_input, Copilot's toolArgs, the Copilot app's toolCalls
def commands(input)
  calls = input["toolCalls"] || [{ "args" => input["tool_input"] || input["toolArgs"] }]
  calls.filter_map do |call|
    args = call.is_a?(Hash) ? call["args"] : nil
    args = JSON.parse(args) if args.is_a?(String)
    args["command"] if args.is_a?(Hash)
  end
end

begin
  message = nil
  commands(JSON.parse($stdin.read)).each { |command| break if (message = GitGuard.violation(command)) }
rescue StandardError
  exit 0
end
exit 0 unless message

# Exit 2 blocks in both tools: Claude Code shows stderr to the model; Copilot denies a failing hook and reads stdout
puts JSON.generate(permissionDecision: "deny", permissionDecisionReason: message)
warn message
exit 2
