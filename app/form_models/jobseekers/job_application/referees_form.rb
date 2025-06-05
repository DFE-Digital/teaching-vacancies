module Jobseekers
  module JobApplication
    class RefereesForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      class << self
        def storable_fields
          %i[notify_before_contact_referers]
        end

        def unstorable_fields
          %i[referees_section_completed referees]
        end

        def load_form(model)
          super.merge(referees: model.referees)
                                    .merge(completed_attrs(model, :referees))
        end
      end

      attribute :referees
      attribute :notify_before_contact_referers, :boolean
      validate :at_least_one_most_recent_employer, if: -> { referees_section_completed }

      validates :notify_before_contact_referers, inclusion: { in: [true, false] }

      completed_attribute(:referees)

      def at_least_one_most_recent_employer
        return if referees.any?(&:is_most_recent_employer)

        errors.add(:referees, :must_include_most_recent_employer)
      end
    end
  end
end
