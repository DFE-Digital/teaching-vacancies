require "dfe_sign_in/api/request"
require "dfe_sign_in/api/response"

module DfeSignIn
  module API
    APPROVERS_ENDPOINT = "/users/approvers".freeze
    APPROVERS_PAGE_SIZE = 275
    USERS_ENDPOINT = "/users".freeze
    USERS_PAGE_SIZE = 275

    def dsi_users
      users_pagination.results
    end

    # The total number of pages of users, so a caller can fan out one job per page
    # rather than fetching them all serially in a single long-running job.
    def dsi_users_page_count
      users_pagination.number_of_pages
    end

    def dsi_users_page(page)
      users_pagination.page(page)
    end

    def dsi_approvers
      approvers_pagination.results
    end

    def dsi_approvers_page_count
      approvers_pagination.number_of_pages
    end

    def dsi_approvers_page(page)
      approvers_pagination.page(page)
    end

    private

    def users_pagination
      PaginatedUsers.new(USERS_ENDPOINT, USERS_PAGE_SIZE)
    end

    def approvers_pagination
      PaginatedUsers.new(APPROVERS_ENDPOINT, APPROVERS_PAGE_SIZE)
    end

    class PaginatedUsers
      attr_reader :endpoint, :page_size

      def initialize(endpoint, page_size)
        @endpoint = endpoint
        @page_size = page_size
      end

      def results
        # First page request to get the total number of pages
        first_page = fetch(1)

        (1..first_page.number_of_pages).lazy.map do |page|
          page == 1 ? first_page.users : fetch(page).users # We already have the response for page 1
        end
      end

      def number_of_pages
        fetch(1).number_of_pages
      end

      def page(page_number)
        fetch(page_number).users
      end

      private

      def fetch(page_number)
        DfeSignIn::API::Response.new(DfeSignIn::API::Request.new(endpoint, page_number, page_size))
      end
    end
  end
end
