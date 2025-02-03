module Jobseekers
  module JobApplication
    class NonCatholicForm < ReligiousInformationForm
      class << self
        def storable_fields
          super + [:ethos_and_aims]
        end

        def unstorable_fields
          %i[non_catholic_section_completed]
        end

        def load_form(model)
          super.merge(completed_attrs(model, :non_catholic))
        end
      end

      attr_accessor(:ethos_and_aims)

      validates_presence_of :ethos_and_aims

      validates :religious_reference_type, inclusion: { in: %w[referee no_referee], nil: false }, if: -> { non_catholic_section_completed && following_religion }

      completed_attribute(:non_catholic)

      def section_completed
        non_catholic_section_completed
      end
    end
  end
end
