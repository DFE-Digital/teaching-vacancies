# frozen_string_literal: true

module Referees
  class ReferenceInformationForm < ReferenceForm
    JobReference::REFERENCE_INFO_FIELDS.each do |field_name|
      attribute field_name, :boolean
      validates field_name, inclusion: { in: [true, false], allow_nil: false }
    end

    MAX_REFERENCE_FIELD_LENGTH = 200

    JobReference::REASON_FIELDS.each do |field_name|
      attribute field_name, :string
      validates field_name, length: { maximum: MAX_REFERENCE_FIELD_LENGTH }
    end

    validates :under_investigation_details, presence: true, if: -> { under_investigation }
    validates :warning_details, presence: true, if: -> { warnings }
    validates :unable_to_undertake_reason, presence: true, unless: -> { able_to_undertake_role }

    class << self
      def storable_fields
        JobReference::REFERENCE_INFO_FIELDS + JobReference::REASON_FIELDS
      end
    end
  end
end
