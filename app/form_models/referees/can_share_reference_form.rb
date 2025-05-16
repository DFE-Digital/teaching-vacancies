# frozen_string_literal: true

module Referees
  class CanShareReferenceForm < ReferenceForm
    attribute :is_reference_sharable, :boolean

    validates :is_reference_sharable, inclusion: { in: [true, false], allow_nil: false }

    class << self
      def storable_fields
        [:is_reference_sharable]
      end
    end
  end
end
