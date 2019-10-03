module DFESignIn
  class ExternalServerError < StandardError; end
  class ForbiddenRequestError < StandardError; end

  class API
    def users(page: 1)
      token = generate_jwt_token
      response = HTTParty.get(
        api_url(page),
        headers: { 'Authorization' => "Bearer #{token}" }
      )

      raise ExternalServerError if response.code.eql?(500)
      raise ForbiddenRequestError if response.code.eql?(403)

      JSON.parse(response&.body) if response.code.eql?(200)
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
