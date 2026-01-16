# frozen_string_literal: true

module Publishers
  module JobListing
    class ExpiryDateTimeForm < ::BaseForm
      include ActiveRecord::AttributeAssignment
      include DateAttributeAssignment

      attr_writer :completed_steps, :current_organisation

      attr_accessor :expiry_time, :publish_on
      attr_reader :expires_at

      validates :expires_at, date: { on_or_after: :now, on_or_before: :far_future, after: :publish_on }
      validates :expiry_time, inclusion: { in: Vacancy::EXPIRY_TIME_OPTIONS }

      class << self
        def fields
          %i[expires_at]
        end

        def load_form(model)
          model.slice(*fields)
        end
      end

      def initialize(params)
        @expiry_time = params[:expiry_time] || params[:expires_at]&.strftime("%k:%M")&.strip

        @params = params
        super
      end

      def params_to_save
        { expires_at: expires_at }
      end

      def expires_at=(value)
        expires_on = date_from_multiparameter_hash(value)
        @expires_at = datetime_from_date_and_time(expires_on, expiry_time)
      end

      def steps_to_reset
        []
      end

      private

      attr_reader :params
    end
  end
end
