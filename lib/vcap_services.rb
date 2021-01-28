# Retrieve service URLs from CloudFoundry VCAP_SERVICES
class VcapServices
  def initialize(vcap_services_env)
    @services = JSON.parse(vcap_services_env)
  end

  def service_url(service_type)
    candidates = services_of_type(service_type)
    raise "VCAP_SERVICES has no services of type '#{service_type}'" if candidates.blank?

    candidates.first.dig("credentials", "uri")
  end

  def named_service_url(service_type, name)
    candidates = services_of_type(service_type).select { |service| service["name"].start_with?(name) }
    raise "VCAP_SERVICES has no '#{name}' services of type '#{service_type}'" if candidates.blank?

    candidates.first.dig("credentials", "uri")
  end

  private

  def services_of_type(service_type)
    @services[service_type.to_s] || []
  end
end
