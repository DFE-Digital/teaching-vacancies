#!/usr/bin/env ruby
# PreToolUse hook (Bash): block git commands that bypass the repository's safety controls (see AGENTS.md).
# Exit 2 blocks the command and shows the message to Claude; anything unparseable is let through.
require "json"
require "shellwords"

OPERATORS = %w[; && || | &].freeze

# Flags in a short-option cluster such as "-nm"; characters after an option that takes an argument are that argument
def short_flags(word, arg_chars)
  return [] unless word.match?(/\A-[a-zA-Z]/)

  word[1..].chars.slice_after { |c| arg_chars.include?(c) }.first
end

begin
  command = JSON.parse($stdin.read).dig("tool_input", "command").to_s
  # Pad operators so "a|git add -f" splits; padding inside quotes only alters message text
  tokens = command.gsub(/(\|\||&&|[;|&])/, ' \1 ').shellsplit
rescue StandardError
  exit 0
end

tokens.slice_when { |_, b| OPERATORS.include?(b) }.each do |words|
  words = words.drop_while { |w| OPERATORS.include?(w) }
  index = words.index("git") or next
  args = words.drop(index + 1)
  args = args.drop(2) while %w[-C -c].include?(args.first)
  args = args.drop(1) while args.first&.start_with?("-")
  subcommand, *rest = args

  case subcommand
  when "add"
    if rest.include?("--force") || rest.any? { |w| short_flags(w, "").include?("f") }
      warn "Blocked: never force-add gitignored files. If git add refuses, that is the control working (AGENTS.md)."
      exit 2
    end
  when "commit"
    if rest.include?("--no-verify") || rest.any? { |w| short_flags(w, "mFcCt").include?("n") }
      warn "Blocked: do not skip the git-secrets commit hooks with --no-verify."
      exit 2
    end
  end
end
