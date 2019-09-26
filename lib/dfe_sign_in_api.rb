module DFESignIn
  class API
    def users(page: 1)
      token = generate_jwt_token
      response = HTTParty.get(
        api_url(page),
        headers: { 'Authorization' => "Bearer #{token}" }
      )
      JSON.parse(response)
    end

    private

    def api_url(page = 1)
      "#{DFE_SIGN_IN_URL}/users?page=#{page}&pageSize=25"
    end

    def generate_jwt_token
      payload = {
        iss: 'schooljobs',
        exp: (Time.now.getlocal + 60).to_i,
        aud: 'signin.education.gov.uk'
      }

      JWT.encode(payload, DFE_SIGN_IN_PASSWORD, 'HS256')
    end
  end
end
