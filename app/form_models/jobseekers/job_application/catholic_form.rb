module Jobseekers
  module JobApplication
    class CatholicForm < ReligiousInformationForm
      include DateAttributeAssignment

      FIELDS = %i[baptism_certificate
                  baptism_address].freeze

      class << self
        def storable_fields
          super + FIELDS + [:baptism_date]
        end

        def unstorable_fields
          %i[catholic_section_completed]
        end

        def load_form(model)
          model.slice(*storable_fields).merge(completed_attrs(model, :catholic))
        end
      end

      attr_accessor(*FIELDS)

      attr_reader(:baptism_date)

      validates :religious_reference_type,
                inclusion: { in: ::JobApplication::RELIGIOUS_REFERENCE_TYPES.keys.map(&:to_s), nil: false },
                if: -> { catholic_section_completed && following_religion }

      completed_attribute(:catholic)

      with_options if: -> { section_completed && following_religion && religious_reference_type == "baptism_date" } do
        validates :baptism_address, presence: true
        validates :baptism_date, tvs_date: { on_or_before: :today }
      end

      validates :baptism_certificate, form_file: Vacancy::DOCUMENT_VALIDATION_OPTIONS, presence: true, if: -> { section_completed && following_religion && religious_reference_type == "baptism_certificate" }

      def baptism_date=(value)
        @baptism_date = date_from_multiparameter_hash(value)
      end

      def section_completed
        catholic_section_completed
      end
    end
  end
end
