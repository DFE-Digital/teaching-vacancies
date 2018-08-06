CONFIG = YAML.safe_load(File.read(File.join(File.dirname(__FILE__), '../../config/browserstack.yml')))

namespace :browserstack do
  RSpec::Core::RakeTask.new(:local) do |t|
    ENV['TEST_BROWSER'] = 'browserstack'
    t.pattern = Dir.glob('spec/features/**/*_spec.rb')
    t.rspec_opts = '--format documentation --tag browserstack'
    t.verbose = false
  end

  task :all do
    next if ENV['BROWSERSTACK_USERNAME'].blank?
    CONFIG['browser_caps'].each_with_index do |_browser, i|
      ENV['TASK_ID'] = i.to_s
      Rake::Task['browserstack:local'].execute
    end
  end

  task default: :local
end
