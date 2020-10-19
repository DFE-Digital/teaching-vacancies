REDIS_URL =
  if ENV['VCAP_SERVICES']
    VCAP_SERVICES = JSON.parse(ENV['VCAP_SERVICES'])
    VCAP_SERVICES['redis'][0]['credentials']['uri']
  else
    'redis://localhost:6379'
  end
