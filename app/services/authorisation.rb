require 'net/http'
module Authorisation
  class Permissions
    attr_reader :response, :headers, :http

    def initialize
      uri = URI.parse(AUTHORISATION_SERVICE_URL)
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = true
      @headers = { 'Authorization' => "Token token=#{AUTHORISATION_SERVICE_TOKEN}",
                   'Content-Type' => 'application/json' }
    end

    def authorise(user_token, school_urn = nil)
      request = Net::HTTP::Get.new("/users/#{user_token}", headers)
      @response = http.request(request)
      @school_urn = school_urn

      user_permissions
    end

    def all_permissions
      user_permissions
    end

    def school_urn
      return nil unless user_permissions.any?
      return user_permissions_for_school.first['school_urn'] if @school_urn.present?

      user_permissions.first['school_urn']
    end

    def many?
      user_permissions && user_permissions.count > 1
    end

    def authorised?
      user_permissions_for_school.any?
    end

    private

    def parsed_response
      response.code == '200' ? JSON.parse(response.body) : nil
    end

    def user_permissions
      @user_permissions ||= parsed_response.present? ? parsed_response['user']['permissions'] : []
    end

    def user_permissions_for_school
      user_permissions.select { |permission| permission['school_urn'] == @school_urn }
    end
  end
end
