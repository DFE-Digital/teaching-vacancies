# Shared rule for agent hooks: autocorrect and lint a file an agent just edited.
# Harness-agnostic; each harness has its own adapter that calls this.
require "open3"

module FileLinter
  # Returns the remaining offences as text, or nil if the file is clean, not lintable, or the bundle is unavailable.
  def self.offences(path)
    return if path.to_s.empty? || !File.file?(path)

    command = command_for(path) or return
    return unless bundle_ready?

    output, status = Open3.capture2e(*command)
    output unless status.success?
  end

  def self.command_for(path)
    case path
    when /\.(rb|rake)\z/, %r{(\A|/)Gemfile\z}
      %W[bundle exec rubocop --autocorrect --force-exclusion --format simple #{path}]
    when /\.slim\z/
      %W[bundle exec slim-lint #{path}]
    end
  end

  def self.bundle_ready?
    system("bundle", "check", out: File::NULL, err: File::NULL)
  rescue SystemCallError
    false
  end
end
