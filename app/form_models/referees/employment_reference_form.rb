# frozen_string_literal: true

module Referees
  class EmploymentReferenceForm < ReferenceForm
    include ActiveRecord::AttributeAssignment

    STRING_FIELDS = %i[how_do_you_know_the_candidate reason_for_leaving would_reemploy_current_reason would_reemploy_any_reason].freeze

    STRING_FIELDS.each do |field|
      attribute field, :string
      validates field, presence: true
    end

    BOOLEAN_FIELDS = %i[currently_employed would_reemploy_current would_reemploy_any].freeze

    BOOLEAN_FIELDS.each do |field|
      attribute field, :boolean
      validates field, inclusion: { in: [true, false], allow_nil: false }
    end

    attribute :employment_start_date, :date_or_hash
    validates :employment_start_date, date: { before: :today }

    class << self
      def storable_fields
        STRING_FIELDS + BOOLEAN_FIELDS + [:employment_start_date]
      end
    end
  end
end
