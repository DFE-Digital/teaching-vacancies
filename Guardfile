# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist")}
# directories %w[app config lib spec .]

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# NOTE: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separately)
#  * 'just' rspec: 'rspec'

guard :bundler do
  require "guard/bundler"
  require "guard/bundler/verify"
  helper = Guard::Bundler::Verify.new

  files = %w[Gemfile]
  files += Dir["*.gemspec"] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end

rspec_options = {
  cmd: "bundle exec rspec",
  run_all: {
    cmd: "bundle exec parallel_rspec -o '",
    cmd_additional_args: "'",
  },
}

guard :rspec, rspec_options do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # Feel free to open issues for suggestions and improvements

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Rails files
  rails = dsl.rails(view_extensions: %w[yml slim])
  dsl.watch_spec_files_for(rails.app_files)
  dsl.watch_spec_files_for(rails.views)

  watch(rails.controllers) do |m|
    [
      rspec.spec.call("routing/#{m[1]}_routing"),
      rspec.spec.call("requests/#{m[1]}"),
    ]
  end

  watch(rails.view_dirs)       { |m| rspec.spec.call("requests/#{m[1]}") }

  # Rails config changes
  watch(rails.spec_helper)     { rspec.spec_dir }
  watch(rails.routes)          { "#{rspec.spec_dir}/routing" }
  watch(rails.app_controller)  { "#{rspec.spec_dir}/requests" }

  # Capybara features specs - probably too heavy a trigger for now
  watch(rails.controllers) do |m|
    system_spec_name = m[1].split("/")
    # This would be ideal, but our system specs don't have names that match the controllers that they test
    system_spec = "#{system_spec_name.first}/#{system_spec_name.join('_')}"
    rspec.spec.call("system/#{system_spec}")
    #   "#{rspec.spec_dir}/system/#{system_spec_name.first}"
  end

  watch(rails.view_dirs) do |m|
    system_spec_name = m[1].split("/")
    system_spec = "#{system_spec_name.first}/#{system_spec_name.join('_')}"
    rspec.spec.call("system/#{system_spec}")
    #   "#{rspec.spec_dir}/system/#{system_spec_name.first}"
  end
end

guard :rubocop, cli: ["-A"], all_on_start: false do
  watch(%r{.+\.rb$})
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end

# Guard-SlimLint supports a lot options with default values:
# all_on_start: true        # Check all files at Guard startup. default: true
# slim_dires: ['app/views'] # Check Directories. default: 'app/views' or '.'
# cli: '--no-color' # Additional command line options to slim-lint.
guard :slim_lint, all_on_start: false do
  watch(%r{.+\.html.*\.slim$})
  watch(%r{(?:.+/)?\.slim-lint\.yml$}) { |m| File.dirname(m[0]) }
end

guard :shell do
  watch %r{^app/models/*\.rb$} do
    system "bundle exec database_consistency"
  end
  watch ".database_consistency.yml" do
    system "bundle exec database_consistency"
  end
  watch "db/schema.rb" do
    system "bundle exec database_consistency"
  end
end
