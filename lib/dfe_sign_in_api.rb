module DFESignIn
  class ExternalServerError < StandardError; end
  class ForbiddenRequestError < StandardError; end
  class UnknownResponseError < StandardError; end

  class API
    PAGE_SIZE = 1000

    def users(page: 1)
      perform_request('/users', page)
    end

    def approvers(page: 1)
      perform_request('/users/approvers', page)
    end

    private

    def perform_request(endpoint, page)
      token = generate_jwt_token
      response = HTTParty.get(
        "#{DFE_SIGN_IN_URL}#{endpoint}?page=#{page}&pageSize=#{PAGE_SIZE}",
        headers: { 'Authorization' => "Bearer #{token}" }
      )

      raise ExternalServerError if response.code.eql?(500)
      raise ForbiddenRequestError if response.code.eql?(403)
      raise UnknownResponseError unless response.code.eql?(200)

      JSON.parse(response.body)
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
