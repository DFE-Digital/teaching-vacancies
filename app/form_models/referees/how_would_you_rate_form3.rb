# frozen_string_literal: true

module Referees
  class HowWouldYouRateForm3 < ReferenceForm
    JobReference::RATINGS_FIELDS_3.each do |field_name|
      attribute field_name, :string
      validates field_name, presence: true
    end

    class << self
      def storable_fields
        JobReference::RATINGS_FIELDS_3
      end
    end
  end
end
