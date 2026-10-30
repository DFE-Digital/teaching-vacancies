# Shared rule for agent hooks: detect git commands that bypass the repository's safety controls
# (see AGENTS.md). Harness-agnostic; each harness has its own adapter that calls this.
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
    when "add" then force_add_message if force_add?(rest)
    when "commit" then no_verify_message if no_verify?(rest)
    end
  end

  def self.force_add?(args)
    args.include?("--force") || args.any? { |w| short_flags(w, "").include?("f") }
  end

  def self.no_verify?(args)
    args.include?("--no-verify") || args.any? { |w| short_flags(w, "mFcCt").include?("n") }
  end

  def self.force_add_message
    "Blocked: never force-add gitignored files. If git add refuses, that is the control working (AGENTS.md)."
  end

  def self.no_verify_message
    "Blocked: do not skip the git-secrets commit hooks with --no-verify."
  end

  # Flags in a short-option cluster such as "-nm"; characters after an option that takes an argument are that argument
  def self.short_flags(word, arg_chars)
    return [] unless word.match?(/\A-[a-zA-Z]/)

    word[1..].chars.slice_after { |c| arg_chars.include?(c) }.first
  end
end
