if ENV['VCAP_SERVICES']
  VCAP_SERVICES = JSON.parse(ENV['VCAP_SERVICES'])
  ELASTICSEARCH_URL = VCAP_SERVICES['elasticsearch'][0]['credentials']['uri']
  REDIS_URL = VCAP_SERVICES['redis'][0]['credentials']['uri']

  ENV['ELASTICSEARCH_URL'] = ELASTICSEARCH_URL
  ENV['REDIS_QUEUE_URL'] = REDIS_URL
  ENV['REDIS_CACHE_URL'] = REDIS_URL
end

ENV['ELASTICSEARCH_URL'] ||= 'http://localhost:9200'
ENV['REDIS_QUEUE_URL'] ||= 'redis://localhost:6379'
ENV['REDIS_CACHE_URL'] ||= 'redis://localhost:6379'
