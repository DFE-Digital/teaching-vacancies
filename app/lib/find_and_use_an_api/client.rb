# Client for the DfE "Find and Use an API" (FaUAPI) Automation API, which lets us keep the
# ATS API's catalogue entry up to date without anyone editing it by hand.
#
# https://tech-docs.teacherservices.cloud/documenting-an-api/documenting-sd-apis-in-fauapi.html
#
# The base URL points at the API management host for the environment (pre-production for
# staging, production for production) and the token is the "Automation Token" taken from the
# FaUAPI workspace.
module FindAndUseAnApi
  class Client
    class HttpError < StandardError; end

    SUCCESS_STATUSES = [200, 201, 204].freeze

    class << self
      def import(manifest)
        post("/api/tasks/apis/import", manifest)
      end

      def list_apis
        get("/api/tasks/apis")
      end

      def publish(api_id)
        put("/api/tasks/apis/#{api_id}/publish")
      end

      private

      def get(path)
        handle_response(connection.get(path))
      end

      def post(path, body)
        handle_response(connection.post(path, body.to_json))
      end

      def put(path)
        handle_response(connection.put(path))
      end

      # `HttpClient` only retries GETs by default, which is what we want here: a retried import
      # or publish could race with the one that appeared to fail. A failed publish is reported
      # and picked up by the next deploy instead.
      def connection
        HttpClient.connection(url: ENV.fetch("FAUAPI_BASE_URL", nil)) do |conn|
          conn.headers["Accept"] = "application/json"
          conn.headers["Content-Type"] = "application/json"
          conn.headers["Authorization"] = "Bearer #{ENV.fetch('FAUAPI_API_KEY', nil)}"
        end
      end

      # Deliberately reports the status and body only. The request headers carry the automation
      # token, and this message ends up in the application logs and in Sentry.
      def handle_response(response)
        raise HttpError, "Find and Use an API responded #{response.status}: #{response.body}" unless SUCCESS_STATUSES.include?(response.status)

        parse_body(response)
      end

      def parse_body(response)
        body = response.body.to_s
        return {} if body.blank?

        JSON.parse(body)
      end
    end
  end
end
