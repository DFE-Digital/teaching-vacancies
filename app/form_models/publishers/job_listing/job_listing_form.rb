# frozen_string_literal: true

module Publishers
  module JobListing
    class JobListingForm < ::BaseForm
      include ActiveModel::Attributes

      class << self
        # rubocop:disable Lint/UnusedMethodArgument
        def load_from_model(vacancy, current_publisher:)
          new(vacancy.slice(*fields))
        end

        def load_from_params(form_params, _vacancy, current_publisher:)
          new(form_params)
        end
        # rubocop:enable Lint/UnusedMethodArgument
      end

      def steps_to_reset
        []
      end

      def params_to_save
        self.class.fields.index_with { |field| public_send(field) }
      end
    end
  end
end
