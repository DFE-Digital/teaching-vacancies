class Authorisation
  class ExternalServerError < StandardError; end

  attr_accessor :organisation_id,
                :user_id,
                :role_ids,
                :dfe_sign_in_url,
                :dfe_sign_in_password,
                :dfe_sign_in_service_id,
                :dfe_sign_in_service_access_role_id

  def initialize(organisation_id:, user_id:)
    self.organisation_id = organisation_id
    self.user_id = user_id
    self.dfe_sign_in_url = DFE_SIGN_IN_URL
    self.dfe_sign_in_password = DFE_SIGN_IN_PASSWORD
    self.dfe_sign_in_service_id = DFE_SIGN_IN_SERVICE_ID
    self.dfe_sign_in_service_access_role_id = DFE_SIGN_IN_SERVICE_ACCESS_ROLE_ID
  end

  def call
    response = build_response

    raise ExternalServerError if response.code.eql?('500')

    if response.code.eql?('200')
      body_hash = JSON.parse(response.body)
      self.role_ids = body_hash['roles'].map { |role| role['id'] }
    end

    self
  end

  def authorised?
    return false if role_ids.blank?

    role_ids.include?(dfe_sign_in_service_access_role_id)
  end

  def many?
    response = JSON.parse(retrieve_organisations.body)
    return true if response.count > 1

    false
  end

  private

  def generate_jwt_token
    payload = {
      iss: 'schooljobs',
      exp: (Time.now.getlocal + 60).to_i,
      aud: 'signin.education.gov.uk'
    }
    JWT.encode(payload, dfe_sign_in_password, 'HS256')
  end

  def build_response
    uri = URI(dfe_sign_in_url)
    uri.path = "/services/#{dfe_sign_in_service_id}/organisations/#{organisation_id}/users/#{user_id}"

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "bearer #{generate_jwt_token}"
    request['Content-Type'] = 'application/json'

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  end

  def retrieve_organisations
    uri = URI(dfe_sign_in_url)
    # "https://test-url.local/users/#{user_id}/organisations"
    uri.path = "/users/#{user_id}/organisations"

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "bearer #{generate_jwt_token}"
    request['Content-Type'] = 'application/json'

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  end
end
