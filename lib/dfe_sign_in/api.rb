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
      # Transient failures are retried per page rather than left to the job-level
      # `retry_on`, because retrying the job restarts pagination from page one: every page
      # that had already succeeded gets fetched and processed again.
      RETRYABLE_ERRORS = [
        DfeSignIn::API::Request::ExternalServerError,
        Net::OpenTimeout,
        Net::ReadTimeout,
      ].freeze
      PAGE_ATTEMPTS = 3
      RETRY_WAIT_SECONDS = 5

      attr_reader :endpoint, :page_size

      def initialize(endpoint, page_size)
        @endpoint = endpoint
        @page_size = page_size
      end

      def results
        # First page request to get the total number of pages
        response = fetch_page(1)

        (1..response.number_of_pages).lazy.map do |page|
          response = fetch_page(page) unless page == 1 # We already have the response for page 1

          response.users
        end
      end

      private

      def fetch_page(page)
        attempts = 0

        begin
          attempts += 1
          DfeSignIn::API::Response.new(DfeSignIn::API::Request.new(endpoint, page, page_size))
        rescue *RETRYABLE_ERRORS => e
          raise if attempts >= PAGE_ATTEMPTS

          Rails.logger.warn("DSI API #{endpoint} page #{page} failed with #{e.class}, " \
                            "retrying (attempt #{attempts} of #{PAGE_ATTEMPTS})")
          sleep(RETRY_WAIT_SECONDS)
          retry
        end
      end
    end
  end
end
