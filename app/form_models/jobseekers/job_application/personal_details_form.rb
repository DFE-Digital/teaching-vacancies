module Jobseekers
  module JobApplication
    class PersonalDetailsForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      FIELDS = %i[
        city country
        email_address
        first_name
        last_name
        phone_number
        previous_names
        postcode
        street_address
        right_to_work_in_uk
        working_patterns
        working_pattern_details
      ].freeze

      WORKING_PATTERNS = %i[full_time part_time job_share].freeze

      attr_accessor(*(FIELDS + [:has_ni_number]))
      attr_writer :national_insurance_number

      attribute :working_patterns, default: []

      def national_insurance_number
        @national_insurance_number if has_ni_number == "yes"
      end

      def working_pattern_options
        WORKING_PATTERNS.to_h { |opt| [opt.to_s, I18n.t("helpers.label.publishers_job_listing_working_patterns_form.working_patterns_options.#{opt}")] }
      end

      class << self
        def storable_fields
          FIELDS + %i[national_insurance_number]
        end

        def unstorable_fields
          %i[has_ni_number personal_details_section_completed]
        end

        def load_form(model)
          new_attrs = {
            has_ni_number: model.national_insurance_number.present? ? "yes" : "no",
          }.merge(completed_attrs(model, :personal_details))
          super.merge(new_attrs)
        end

        def fields
          super + [{ working_patterns: [] }]
        end
      end

      validates :city, :country, :email_address, :first_name, :last_name,
                :phone_number, :postcode, :street_address, presence: true, if: -> { personal_details_section_completed }

      validates :national_insurance_number, format: { with: /\A\s*[a-zA-Z]{2}(?:\s*\d\s*){6}[a-zA-Z]?\s*\z/ }, allow_blank: true
      validates :has_ni_number, inclusion: { in: %w[yes no], allow_nil: false }, if: -> { personal_details_section_completed }
      validates :national_insurance_number, presence: true, if: -> { has_ni_number == "yes" }

      validates :phone_number, format: { with: /\A\+?(?:\d\s?){10,13}\z/ }, if: -> { personal_details_section_completed }
      validates :email_address, email_address: true
      validates :right_to_work_in_uk, inclusion: { in: %w[yes no] }, if: -> { personal_details_section_completed }
      validates :working_patterns, presence: true
      validate :working_pattern_details_does_not_exceed_maximum_words

      completed_attribute(:personal_details)

      def working_pattern_details_does_not_exceed_maximum_words
        if number_of_words_exceeds_permitted_length?(50, working_pattern_details)
          errors.add(:working_pattern_details, :length)
        end
      end
    end
  end
end
