# frozen_string_literal: true

module Referees
  class HowWouldYouRateForm1 < ReferenceForm
    JobReference::RATINGS_FIELDS_1.each do |field_name|
      attribute field_name, :string
      validates field_name, presence: true
    end

    class << self
      def storable_fields
        JobReference::RATINGS_FIELDS_1
      end
    end
  end
end
