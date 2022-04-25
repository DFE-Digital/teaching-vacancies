namespace :cf do
  desc "Only run on the first application instance"
  task :on_first_instance do
    exit(0) unless ENV.fetch("CF_INSTANCE_INDEX", nil) == "0"
  end
end
