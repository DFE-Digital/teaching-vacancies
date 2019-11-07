namespace :cf do
  desc 'Only run on the first application instance'
  task :on_first_instance do # rubocop:disable Rails/RakeEnvironment
    instance_index = JSON.parse(ENV['VCAP_APPLICATION'])['instance_index'] rescue nil
    exit(0) unless instance_index.zero?
  end
end
