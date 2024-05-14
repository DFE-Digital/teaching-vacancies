require "dfe_sign_in/api/request"
require "dfe_sign_in/api/response"

module DfeSignIn
  module API
    APPROVERS_ENDPOINT = "/users/approvers".freeze
    APPROVERS_PAGE_SIZE = 275
    USERS_ENDPOINT = "/users".freeze
    USERS_PAGE_SIZE = 275

    def dsi_users
      PaginatedUsers.new(USERS_ENDPOINT, USERS_PAGE_SIZE).results
    end

    def dsi_approvers
      PaginatedUsers.new(APPROVERS_ENDPOINT, APPROVERS_PAGE_SIZE).results
    end

    class PaginatedUsers
      attr_reader :endpoint, :page_size

      def initialize(endpoint, page_size)
        @endpoint = endpoint
        @page_size = page_size
      end

      def results
        # First page request to get the total number of pages
        request = DfeSignIn::API::Request.new(endpoint, 1, page_size)
        response = DfeSignIn::API::Response.new(request)

        (1..response.number_of_pages).lazy.map do |page|
          unless page == 1 # We already have the response for page 1
            request = DfeSignIn::API::Request.new(endpoint, page, page_size)
            response = DfeSignIn::API::Response.new(request)
          end

          response.users
        end
      end
    end
  end
end
