module DfeSignIn
  module API
    class Request
      class ExternalServerError < StandardError; end
      class ForbiddenRequestError < StandardError; end
      class UnknownResponseError < StandardError; end

      def initialize(endpoint, page, page_size)
        @endpoint = endpoint
        @page = page
        @page_size = page_size
      end

      def perform
        token = generate_jwt_token
        response = HTTParty.get(
          "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}#{@endpoint}?page=#{@page}&pageSize=#{@page_size}",
          headers: { "Authorization" => "Bearer #{token}" },
        )

        raise ExternalServerError if response.code.eql?(500)
        raise ForbiddenRequestError if response.code.eql?(403)
        raise UnknownResponseError unless response.code.eql?(200)

        JSON.parse(response.body)
      end

      private

      def generate_jwt_token
        payload = {
          iss: "schooljobs",
          exp: (Time.current.getlocal + 60).to_i,
          aud: "signin.education.gov.uk",
        }

        JWT.encode(payload, ENV.fetch("DFE_SIGN_IN_PASSWORD", nil), "HS256")
      end
    end
  end
end
