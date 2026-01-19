# frozen_string_literal: true

module Referees
  class EmploymentReferenceForm < ReferenceForm
    include ActiveRecord::AttributeAssignment

    STRING_FIELDS = %i[how_do_you_know_the_candidate reason_for_leaving would_reemploy_current_reason would_reemploy_any_reason].freeze

    MAX_REFERENCE_FIELD_LENGTH = 200

    # errors on form displayed in same order as declared here...
    attribute :how_do_you_know_the_candidate, :string
    attribute :employment_start_date, :date_or_hash
    attribute :currently_employed, :boolean
    attribute :employment_end_date, :date_or_hash
    attribute :reason_for_leaving, :string
    attribute :would_reemploy_current, :boolean
    attribute :would_reemploy_current_reason, :string
    attribute :would_reemploy_any, :boolean
    attribute :would_reemploy_any_reason, :string

    STRING_FIELDS.each do |field|
      validates field, presence: true, length: { maximum: MAX_REFERENCE_FIELD_LENGTH }
    end

    BOOLEAN_FIELDS = %i[currently_employed would_reemploy_current would_reemploy_any].freeze

    BOOLEAN_FIELDS.each do |field|
      validates field, inclusion: { in: [true, false], allow_nil: false }
    end

    validates :employment_start_date, tvs_date: { before: :today }
    validates :employment_end_date, tvs_date: { before: :today, after: :employment_start_date, allow_nil: false }, unless: -> { currently_employed }

    class << self
      def storable_fields
        STRING_FIELDS + BOOLEAN_FIELDS + %i[employment_start_date employment_end_date]
      end
    end
  end
end
