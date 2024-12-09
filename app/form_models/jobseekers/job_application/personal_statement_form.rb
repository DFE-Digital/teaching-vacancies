class Jobseekers::JobApplication::PersonalStatementForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  FIELDS = %i[personal_statement].freeze

  class << self
    def fields
      FIELDS + [:personal_statement_section_completed]
    end

    def unstorable_fields
      %i[personal_statement_section_completed]
    end

    def load_form(model)
      new_attrs = { }
      if model.completed_steps.include?('personal_statement')
        new_attrs.merge!(personal_statement_section_completed: true)
      elsif model.in_progress_steps.include?('personal_statement')
        new_attrs.merge!(personal_statement_section_completed: false)
      end
      load_form_attributes(model.attributes.merge(new_attrs))
    end
  end
  attr_accessor(*FIELDS)

  attribute :personal_statement_section_completed, :boolean

  validates :personal_statement, presence: true, if: -> { personal_statement_section_completed }
  validates :personal_statement_section_completed, inclusion: { in: [true, false], allow_nil: false }
end
