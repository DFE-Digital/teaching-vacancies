module Jobseekers
  module UploadedJobApplication
    class PersonalDetailsForm < Jobseekers::JobApplication::BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Jobseekers::JobApplication::CompletedFormAttribute

      FIELDS = %i[
        first_name
        last_name
        phone_number
        email_address
        teacher_reference_number
      ].freeze

      attr_accessor(*FIELDS)

      class << self
        def storable_fields
          FIELDS + %i[has_right_to_work_in_uk]
        end

        def load_form(model)
          super.merge(completed_attrs(model, :personal_details))
        end
      end

      validates :first_name, :last_name, :phone_number, :email_address, presence: true, if: -> { personal_details_section_completed }
      validates :phone_number, format: { with: /\A\+?(?:\d\s?){10,13}\z/ }, if: -> { personal_details_section_completed }
      validates :email_address, email_address: true
      attribute :has_right_to_work_in_uk, :boolean
      validates :has_right_to_work_in_uk, inclusion: { in: [true, false] }, if: -> { personal_details_section_completed }
      validates_format_of :teacher_reference_number, with: /\A\d{7}\z/, allow_blank: true

      completed_attribute(:personal_details)
    end
  end
end
