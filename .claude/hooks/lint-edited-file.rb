#!/usr/bin/env ruby
# PostToolUse hook for file edits: autocorrects the edited Ruby or Slim files and reports any remaining offences.
# Claude Code and GitHub Copilot (CLI and app) both run it from .claude/settings.json.
require "json"
require "open3"

def lint_command(path)
  case path
  when /\.(rb|rake)\z/, %r{(\A|/)Gemfile\z}
    %W[bundle exec rubocop --autocorrect --force-exclusion --format simple #{path}]
  when /\.slim\z/
    %W[bundle exec slim-lint #{path}]
  end
end

def parse_json(text)
  JSON.parse(text)
rescue JSON::ParserError
  text
end

# Copilot's apply_patch edits files through a patch body ("*** Update File: path"), not a file_path argument
def paths(args)
  args = parse_json(args) if args.is_a?(String)
  case args
  when Hash then Array(args["file_path"] || args["path"]) + paths(args["input"] || args["patch"])
  when String then args.scan(/^\*\*\* (?:Add|Update) File: (.+)$/).flatten
  else []
  end
end

def edited_paths(input)
  calls = input["toolCalls"] || [{ "args" => input["tool_input"] || input["toolArgs"] }]
  calls.flat_map { |call| call.is_a?(Hash) ? paths(call["args"]) : [] }.select { |path| File.file?(path) }.uniq
end

begin
  input = JSON.parse($stdin.read)
  files = edited_paths(input).select { |path| lint_command(path) }
  exit 0 if files.empty? || !system("bundle", "check", out: File::NULL, err: File::NULL)

  messages = files.filter_map do |path|
    output, status = Open3.capture2e(*lint_command(path))
    "Lint offences remain in #{path}:\n#{output}" unless status.success?
  end
rescue StandardError
  exit 0
end
exit 0 if messages.empty?

message = messages.join("\n")
# Copilot shows the model only stdout's additionalContext; Claude Code shows stderr when the hook exits 2
if ENV["COPILOT_PROJECT_DIR"] || input.key?("toolCalls") || input.key?("toolName")
  puts JSON.generate(additionalContext: message)
  exit 0
end
warn message
exit 2
