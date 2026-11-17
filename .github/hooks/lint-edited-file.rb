#!/usr/bin/env ruby
# GitHub Copilot postToolUse hook. The rule lives in .agents/hooks/lib/file_linter.rb.
# Copilot shows the model only stdout's additionalContext, and always exit 0 so a lint run never fails the tool.
require "json"
require_relative "../../.agents/hooks/lib/file_linter"

# apply_patch is excluded: it carries a patch body rather than a path argument
EDIT_TOOLS = %w[create edit str_replace_editor].freeze

begin
  input = JSON.parse($stdin.read)
  # Read-only tools (view, grep, glob) also carry a path and must not trigger autocorrect
  exit 0 unless EDIT_TOOLS.include?(input["toolName"])

  args = input["toolArgs"]
  args = JSON.parse(args) if args.is_a?(String)
  exit 0 unless args.is_a?(Hash)

  path = args["path"] || args["filePath"] || args["file_path"]
  exit 0 unless path

  path = File.expand_path(path, input["cwd"] || Dir.pwd)
  output = FileLinter.offences(path)
rescue StandardError
  exit 0
end

puts JSON.generate(additionalContext: "Lint offences remain in #{path}:\n#{output}") if output
exit 0
