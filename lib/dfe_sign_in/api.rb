require "jwt"

module DfeSignIn
  # A thin client for the DfE Sign In users API. It hands back lazy Enumerators of raw DSI
  # user hashes, so callers can just loop (`DfeSignIn::API.users.each { |user| ... }`)
  # without knowing the API is paginated underneath.
  module API
    # Faraday's :raise_error middleware sits inside HttpClient's retry middleware, so it raises
    # before retry sees the status. The errors worth retrying are added to retry's exceptions.
    RETRIED_ERRORS = [Faraday::ServerError, Faraday::TooManyRequestsError].freeze

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
        connection.get(endpoint, page: page, pageSize: page_size).body
      end

      # The token is a proc so every request, including each retry, is signed afresh.
      # :raise_error goes after :json so it checks the status before the body is parsed:
      # responses unwind innermost first.
      def connection
        HttpClient.connection(url: ENV.fetch("DFE_SIGN_IN_URL"), retry_options: retry_options) do |conn|
          conn.request :authorization, "Bearer", -> { jwt_token }
          conn.response :json
          conn.response :raise_error
        end
      end

      def retry_options
        { exceptions: HttpClient::DEFAULT_RETRY_OPTIONS[:exceptions] + RETRIED_ERRORS }
      end

      def jwt_token
        payload = {
          iss: "schooljobs",
          exp: (Time.current.getlocal + 60).to_i,
          aud: "signin.education.gov.uk",
        }

        JWT.encode(payload, ENV.fetch("DFE_SIGN_IN_PASSWORD"), "HS256")
      end
    end
  end
end
