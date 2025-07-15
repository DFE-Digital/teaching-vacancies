# frozen_string_literal: true

module Referees
  class CanGiveReferenceForm < ReferenceForm
    ATTRIBUTES = [:can_give_reference].freeze

    ATTRIBUTES.each do |field|
      attribute field, :boolean

      validates field, inclusion: { in: [true, false], allow_nil: false }
    end

    def params_to_save
      if can_give_reference
        super
      else
        super.merge(complete: true)
      end
    end

    class << self
      def storable_fields
        ATTRIBUTES
      end
    end
  end
end
