require 'net/http'
module TeacherVacancyAuthorisation
  class Permissions
    attr_reader :response, :headers, :http

    def initialize
      uri = URI.parse(AUTHORISATION_SERVICE_URL)
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = true
      @headers = { 'Authorization' => "Token token=#{AUTHORISATION_SERVICE_TOKEN}",
                   'Content-Type' => 'application/json' }
    end

    def authorise(user_token)
      request = Net::HTTP::Get.new("/users/#{user_token}", headers)
      @response = http.request(request)

      user_permissions
    end

    def all_permissions
      user_permissions
    end

    def school_urn
      user_permissions.any? ? user_permissions.first['school_urn'] : nil
    end

    def many?
      user_permissions && user_permissions.count > 1
    end

    private

    def parsed_response
      response.code == '200' ? JSON.parse(response.body) : nil
    end

    def user_permissions
      @user_permissions ||= parsed_response.present? ? parsed_response['user']['permissions'] : []
    end
  end
end
