# frozen_string_literal: true

module Publishers
  module JobListing
    class ExpiryDateTimeForm < JobListingForm
      include ActiveRecord::AttributeAssignment
      include DateAttributeAssignment

      attr_accessor :expiry_time, :publish_on
      attr_reader :expires_at

      validates :expires_at, date: { on_or_after: :now, on_or_before: :far_future, after: :publish_on }
      validates :expiry_time, inclusion: { in: Vacancy::EXPIRY_TIME_OPTIONS }

      class << self
        def fields
          %i[expires_at]
        end
      end

      def initialize(params)
        @expiry_time = params[:expiry_time] || params[:expires_at]&.strftime("%k:%M")&.strip

        super
      end

      def params_to_save
        { expires_at: expires_at }
      end

      def expires_at=(value)
        expires_on = date_from_multiparameter_hash(value)
        @expires_at = datetime_from_date_and_time(expires_on, expiry_time)
      end
    end
  end
end
