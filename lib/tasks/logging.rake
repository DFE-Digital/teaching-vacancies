desc "switch rails logger to stdout"
task verbose: [:environment] do
  Rails.logger = Logger.new($stdout)
end

desc "switch rails logger log level to debug"
task debug: %i[environment verbose] do
  Rails.logger.level = Logger::DEBUG
end
