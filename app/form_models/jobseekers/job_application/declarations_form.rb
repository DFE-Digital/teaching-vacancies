class Jobseekers::JobApplication::DeclarationsForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  FIELDS = %i[close_relationships close_relationships_details right_to_work_in_uk safeguarding_issue safeguarding_issue_details]

  class << self
    def fields
      FIELDS + [:declarations_section_completed]
    end

    def unstorable_fields
      %i[declarations_section_completed]
    end

    def load_form(model)
      new_attrs = { }
      if model.completed_steps.include?('declarations')
        new_attrs.merge!(declarations_section_completed: true)
      elsif model.in_progress_steps.include?('declarations')
        new_attrs.merge!(declarations_section_completed: false)
      end
      load_form_attributes(model.attributes.merge(new_attrs))
    end
  end
  attr_accessor(*FIELDS)

  validates :close_relationships, inclusion: { in: %w[yes no] }
  validates :close_relationships_details, presence: true, if: -> { close_relationships == "yes" }
  validates :safeguarding_issue, inclusion: { in: %w[yes no] }
  validates :safeguarding_issue_details, presence: true, if: -> { safeguarding_issue == "yes" }

  attribute :declarations_section_completed, :boolean

  validates :declarations_section_completed, inclusion: { in: [true, false], allow_nil: false }
end
