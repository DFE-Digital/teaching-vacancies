# frozen_string_literal: true

module Referees
  class RefereeDetailsForm < ReferenceForm
    FIELDS = %i[name job_title phone_number email organisation].freeze

    FIELDS.each do |field_name|
      attribute field_name, :string
    end

    attribute :complete, :boolean

    attribute :complete_and_accurate, :boolean
    validates :complete_and_accurate,
              acceptance: true

    validates :name, presence: true, length: { maximum: 50 }
    validates :job_title, presence: true, length: { maximum: 50 }
    validates :phone_number, format: { with: /\A\+?(?:\d\s?){10,12}\z/ }, allow_blank: true
    validates :email, presence: true, email_address: true
    validates :organisation, presence: true, length: { maximum: 50 }

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
