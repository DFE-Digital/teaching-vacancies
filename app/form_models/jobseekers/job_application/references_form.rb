class Jobseekers::JobApplication::ReferencesForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  class << self
    def fields
      [:references_section_completed]
    end

    def unstorable_fields
      %i[references_section_completed]
    end

    def optional?
      false
    end

    def load_form(model)
      new_attrs = { }
      if model.completed_steps.include?('references')
        new_attrs.merge!(references_section_completed: true)
      elsif model.in_progress_steps.include?('references')
        new_attrs.merge!(references_section_completed: false)
      end
      load_form_attributes(model.attributes.merge(new_attrs))
    end

  end

  attribute :references_section_completed, :boolean

  validates :references_section_completed, inclusion: { in: [true, false], allow_nil: false }
end
