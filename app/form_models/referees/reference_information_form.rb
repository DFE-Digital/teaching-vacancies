# frozen_string_literal: true

module Referees
  class ReferenceInformationForm < ReferenceForm
    FIELDS = %i[
      under_investigation
      warnings
      allegations
      not_fit_to_practice
      able_to_undertake_role
    ].freeze

    FIELDS.each do |field_name|
      attribute field_name, :boolean
      validates field_name, inclusion: { in: [true, false], allow_nil: false }
    end

    class << self
      def storable_fields
        FIELDS
      end
    end
  end
end
