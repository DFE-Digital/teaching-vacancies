# frozen_string_literal: true

module Referees
  class CanShareReferenceForm < ReferenceForm
    ATTRIBUTES = [:is_reference_sharable].freeze

    ATTRIBUTES.each do |field|
      attribute field, :boolean

      validates field, inclusion: { in: [true, false], allow_nil: false }
    end

    class << self
      def storable_fields
        ATTRIBUTES
      end
    end
  end
end
