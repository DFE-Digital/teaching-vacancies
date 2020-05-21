if ENV['VCAP_SERVICES']
  VCAP_SERVICES = JSON.parse(ENV['VCAP_SERVICES'])
  REDIS_URL = VCAP_SERVICES['redis'][0]['credentials']['uri']

  ENV['REDIS_QUEUE_URL'] = REDIS_URL
  ENV['REDIS_CACHE_URL'] = REDIS_URL
end

ENV['REDIS_QUEUE_URL'] ||= 'redis://localhost:6379'
ENV['REDIS_CACHE_URL'] ||= 'redis://localhost:6379'
