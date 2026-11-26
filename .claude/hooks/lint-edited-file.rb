#!/usr/bin/env ruby
# PostToolUse hook for file edits: autocorrects the edited Ruby or Slim files and reports any remaining offences.
# Claude Code runs it from .claude/settings.json (matcher Edit|Write|MultiEdit); GitHub Copilot (CLI and app) runs it
# from .github/hooks/agent-hooks.json, which cannot filter by tool, so the script skips read-only tools itself.
require "json"
require "open3"

# Claude: Edit, Write, MultiEdit. Copilot: edit, create, str_replace_editor, apply_patch. Read-only tools (Read, view,
# grep, glob) also carry a path and must not trigger autocorrect.
EDIT_TOOL = /edit|write|create|patch|replace|insert/i

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
  calls = input["toolCalls"] || [{ "name" => input["tool_name"] || input["toolName"], "args" => input["tool_input"] || input["toolArgs"] }]
  calls = calls.select { |call| call.is_a?(Hash) && (call["toolName"] || call["name"]).to_s.match?(EDIT_TOOL) }
  calls.flat_map { |call| paths(call["args"]) }.select { |path| File.file?(path) }.uniq
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
