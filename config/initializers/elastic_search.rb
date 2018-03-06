require 'faraday_middleware/aws_signers_v4'

if ENV['ELASTICSEARCH_AWS_SIGNING']

  Elasticsearch::Model.client = Elasticsearch::Client.new(host: ENV['ELASTICSEARCH_URL']) do |f|
    f.request :aws_signers_v4,
      credentials: Aws::Credentials.new(ENV['AWS_ELASTICSEARCH_KEY'], ENV['AWS_ELASTICSEARCH_SECRET']),
      service_name: 'es',
      region: ENV['AWS_ELASTICSEARCH_REGION']

    f.response :logger
    f.adapter  Faraday.default_adapter
  end

else
  Elasticsearch::Model.client = Elasticsearch::Client.new(host: ENV['ELASTICSEARCH_URL'])
end
