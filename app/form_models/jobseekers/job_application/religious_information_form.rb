module Jobseekers
  module JobApplication
    class ReligiousInformationForm < BaseForm
      include ActiveRecord::AttributeAssignment
      include ActiveModel::Attributes
      include CompletedFormAttribute

      FIELDS = %i[faith
                  place_of_worship
                  place_of_worship_start_date
                  religious_reference_type
                  religious_referee_name
                  religious_referee_address
                  religious_referee_role
                  religious_referee_email
                  religious_referee_phone].freeze

      STORABLE_FIELDS = (FIELDS + %i[following_religion]).freeze

      class << self
        def storable_fields
          STORABLE_FIELDS
        end
      end

      attr_accessor(*FIELDS)

      attribute :following_religion, :boolean

      validates :following_religion, inclusion: { in: [true, false], allow_nil: false }, if: -> { section_completed }

      validates :faith, presence: true, if: -> { section_completed && following_religion }

      validates :religious_referee_name, :religious_referee_address, :religious_referee_role, :religious_referee_email,
                presence: true, if: -> { section_completed && following_religion && religious_reference_type == "religious_referee" }
      validates :religious_referee_email, email: true, if: -> { section_completed && following_religion && religious_reference_type == "religious_referee" }
    end
  end
end
