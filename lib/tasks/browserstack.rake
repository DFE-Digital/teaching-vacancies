namespace :browserstack do
  RSpec::Core::RakeTask.new(:local) do |t|
    ENV['TEST_BROWSER'] = "browserstack"
    t.pattern = Dir.glob('spec/features/**/*_spec.rb')
    t.rspec_opts = "--format documentation"
    t.verbose = false
  end
  task default: :local
end
