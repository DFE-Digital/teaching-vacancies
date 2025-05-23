# frozen_string_literal: true

module Referees
  class HowWouldYouRateForm < ReferenceForm
    JobReference::RATINGS_FIELDS.each do |field_name|
      attribute field_name, :string
      validates field_name, presence: true
    end

    class << self
      def storable_fields
        JobReference::RATINGS_FIELDS
      end
    end
  end
end
