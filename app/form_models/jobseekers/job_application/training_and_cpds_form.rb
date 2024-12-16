module Jobseekers
  module JobApplication
    class TrainingAndCpdsForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      class << self
        def fields
          %i[training_and_cpds_section_completed]
        end

        def unstorable_fields
          %i[training_and_cpds_section_completed]
        end

        def load_form(model)
          load_form_attributes(model.attributes.merge(completed_attrs(model, :training_and_cpds)))
        end
      end
      attribute :training_and_cpds_section_completed, :boolean

      validates :training_and_cpds_section_completed, inclusion: { in: [true, false], allow_nil: false }
    end
  end
end
