require "jwt"

module DfeSignIn
  # A thin client for the DfE Sign In users API. It hands back lazy Enumerators of raw DSI
  # user hashes, so callers can just loop (`DfeSignIn::API.users.each { |user| ... }`)
  # without knowing the API is paginated underneath.
  module API
    class ForbiddenRequestError < StandardError; end
    class ExternalServerError < StandardError; end
    class UnknownResponseError < StandardError; end

    USERS_ENDPOINT = "/users".freeze
    USERS_PAGE_SIZE = 275
    APPROVERS_ENDPOINT = "/users/approvers".freeze
    APPROVERS_PAGE_SIZE = 275

    class << self
      def users(&)
        return enum_for(:users) unless block_given?

        paginate(USERS_ENDPOINT, USERS_PAGE_SIZE, &)
      end

      def approvers(&)
        return enum_for(:approvers) unless block_given?

        paginate(APPROVERS_ENDPOINT, APPROVERS_PAGE_SIZE, &)
      end

      private

      def paginate(endpoint, page_size, &)
        page = 1

        loop do
          body = fetch(endpoint, page, page_size)
          Array(body["users"]).each(&)

          break if page >= body.fetch("numberOfPages", page)

          page += 1
        end
      end

      def fetch(endpoint, page, page_size)
        response = connection.get(endpoint, page: page, pageSize: page_size)

        raise ExternalServerError if response.status == 500
        raise ForbiddenRequestError if response.status == 403
        raise UnknownResponseError unless response.status == 200

        response.body
      end

      # The status checks stay in #fetch rather than using the :raise_error middleware, which
      # would raise inside HttpClient's retry middleware and stop 5xx responses being retried.
      # The token is a proc so every request, including each retry, is signed afresh.
      def connection
        HttpClient.connection(url: ENV.fetch("DFE_SIGN_IN_URL", nil)) do |conn|
          conn.request :authorization, "Bearer", -> { jwt_token }
          conn.response :json
        end
      end

      def jwt_token
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
