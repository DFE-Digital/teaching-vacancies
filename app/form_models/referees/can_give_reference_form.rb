# frozen_string_literal: true

module Referees
  class CanGiveReferenceForm < ReferenceForm
    BOOLEAN_ATTRIBUTES = [:can_give_reference].freeze

    BOOLEAN_ATTRIBUTES.each do |field|
      attribute field, :boolean

      validates field, inclusion: { in: [true, false], allow_nil: false }
    end

    attribute :not_provided_reason

    def params_to_save
      if can_give_reference
        super
      else
        super.merge(complete: true)
      end
    end

    class << self
      def storable_fields
        BOOLEAN_ATTRIBUTES + [:not_provided_reason]
      end
    end
  end
end
