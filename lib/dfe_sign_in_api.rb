module DFESignIn
  class API
    BASE_URL = DFE_SIGN_IN_URL

    attr_accessor :dfe_sign_in_password

    def initialize
      self.dfe_sign_in_password = DFE_SIGN_IN_PASSWORD
    end

    def users(page: 1)
      token = generate_jwt_token
      response = HTTParty.get(
        api_url(page),
        headers: { 'Authorization' => "Bearer #{token}" }
      )
      JSON.parse(response)
    end

    private

    def api_url(page = 1, records = 25)
      "#{DFE_SIGN_IN_URL}/users?page=#{page}&pageSize=#{records}"
    end

    def generate_jwt_token
      payload = {
        iss: 'schooljobs',
        exp: (Time.now.getlocal + 60).to_i,
        aud: 'signin.education.gov.uk'
      }
      JWT.encode(payload, dfe_sign_in_password, 'HS256')
    end
  end
end
