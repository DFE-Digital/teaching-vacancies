# frozen_string_literal: true

module Referees
  class CanGiveReferenceForm < ReferenceForm
    attribute :can_give_reference, :boolean

    validates :can_give_reference, inclusion: { in: [true, false], allow_nil: false }

    class << self
      def storable_fields
        [:can_give_reference]
      end
    end
  end
end
