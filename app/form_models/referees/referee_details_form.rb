# frozen_string_literal: true

module Referees
  class RefereeDetailsForm < ReferenceForm
    FIELDS = %i[name job_title phone_number email organisation].freeze

    FIELDS.each do |field_name|
      attribute field_name, :string
      validates field_name, presence: true
    end
    validates :email, email_address: true

    attribute :complete, :boolean

    attribute :complete_and_accurate, :boolean
    validates :complete_and_accurate,
              acceptance: true

    class << self
      def unstorable_fields
        [:complete_and_accurate]
      end

      def storable_fields
        FIELDS + [:complete]
      end
    end
  end
end
