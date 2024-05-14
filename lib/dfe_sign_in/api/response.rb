module DfeSignIn
  module API
    class Response
      class NilUsersError < StandardError; end

      attr_reader :response

      def initialize(request)
        @response = request.perform
      end

      def number_of_pages
        raise(error_message) if response["numberOfPages"].nil?

        response["numberOfPages"]
      end

      def users
        raise(DfeSignIn::API::Response::NilUsersError, error_message) if users_nil_or_empty?

        response["users"]
      end

      private

      def error_message
        response["message"] || "failed request"
      end

      def users_nil_or_empty?
        response["users"].blank? || response["users"].first.blank?
      end
    end
  end
end
