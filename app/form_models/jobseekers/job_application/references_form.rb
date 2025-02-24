module Jobseekers
  module JobApplication
    class ReferencesForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      class << self
        def unstorable_fields
          %i[references_section_completed references]
        end

        def load_form(model)
          super.merge(references: model.references)
                                    .merge(completed_attrs(model, :references))
        end
      end

      attribute :references
      validate :at_least_one_most_recent_employer, if: -> { references_section_completed }

      completed_attribute(:references)

      def at_least_one_most_recent_employer
        return if references.any?(&:is_most_recent_employer)

        errors.add(:references, :must_include_most_recent_employer)
      end
    end
  end
end
