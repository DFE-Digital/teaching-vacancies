require "jwt"

module DfeSignIn
  # A thin client for the DfE Sign In users API. It hands back lazy Enumerators of raw DSI
  # user hashes, so callers can just loop (`DfeSignIn::API.users.each { |user| ... }`)
  # without knowing the API is paginated underneath.
  module API
    # Raised for a failed request, or a successful one that isn't a page of users. A response
    # with no users, or no page count, is a DSI failure rather than an empty list: there are
    # always users, and treating it as none would wipe what we hold.
    class UnexpectedResponseError < StandardError; end

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
          users_in(body, endpoint, page).each(&)

          break if page >= body["numberOfPages"]

          page += 1
        end
      end

      # Only DSI's own error message goes in the exception, never the body, which can hold
      # personal data.
      def users_in(body, endpoint, page)
        # Faraday only parses a response labelled as JSON, so anything else (an HTML error
        # page, say) is still a String here.
        raise UnexpectedResponseError, "DSI #{endpoint} returned a response that isn't JSON on page #{page}" unless body.is_a?(Hash)
        return body["users"] if body["users"].present? && body["numberOfPages"].present?

        raise UnexpectedResponseError,
              "DSI #{endpoint} returned no users on page #{page}: #{body['message'] || 'no message'}"
      end

      # HttpClient has already retried a 429 or 5xx by the time the response gets here.
      def fetch(endpoint, page, page_size)
        response = connection.get(endpoint, page: page, pageSize: page_size)
        raise UnexpectedResponseError, "DSI #{endpoint} responded with status #{response.status} on page #{page}" unless response.success?

        response.body
      end

      # The token is a proc so every request, including each retry, is signed afresh.
      def connection
        HttpClient.connection(url: ENV.fetch("DFE_SIGN_IN_URL")) do |conn|
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

        JWT.encode(payload, ENV.fetch("DFE_SIGN_IN_PASSWORD"), "HS256")
      end
    end
  end
end
