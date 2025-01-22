module Jobseekers
  module JobApplication
    class CatholicForm < ReligiousInformationForm
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

      attribute :baptism_date, :date

      validates :religious_reference_type,
                inclusion: { in: ::JobApplication::RELIGIOUS_REFERENCE_TYPES.keys.map(&:to_s), nil: false },
                if: -> { catholic_section_completed && following_religion }

      completed_attribute(:catholic)

      def section_completed
        catholic_section_completed
      end
    end
  end
end
