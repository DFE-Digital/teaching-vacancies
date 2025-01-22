module Jobseekers
  module JobApplication
    class TrainingAndCpdsForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      class << self
        def unstorable_fields
          %i[training_and_cpds_section_completed]
        end

        def load_form(model)
          super.merge(completed_attrs(model, :training_and_cpds))
        end
      end

      completed_attribute(:training_and_cpds)
    end
  end
end
