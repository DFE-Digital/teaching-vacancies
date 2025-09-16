# frozen_string_literal: true

module Referees
  class ReferenceInformationForm < ReferenceForm
    JobReference::REFERENCE_INFO_FIELDS.each do |field_name|
      attribute field_name, :boolean
      validates field_name, inclusion: { in: [true, false], allow_nil: false }
    end

    MAX_REFERENCE_FIELD_LENGTH = 200

    JobReference::REASON_DETAILS_FIELDS.each do |field_name|
      attribute field_name, :string
    end

    validates :under_investigation_details, presence: true, length: { maximum: MAX_REFERENCE_FIELD_LENGTH }, if: -> { under_investigation }
    validates :warning_details, presence: true, length: { maximum: MAX_REFERENCE_FIELD_LENGTH }, if: -> { warnings }
    validates :unable_to_undertake_reason, presence: true, length: { maximum: MAX_REFERENCE_FIELD_LENGTH }, unless: -> { able_to_undertake_role }

    class << self
      def storable_fields
        JobReference::REFERENCE_INFO_FIELDS + JobReference::REASON_DETAILS_FIELDS
      end
    end
  end
end
