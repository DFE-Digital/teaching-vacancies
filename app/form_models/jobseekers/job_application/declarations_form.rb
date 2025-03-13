module Jobseekers
  module JobApplication
    class DeclarationsForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      FIELDS = %i[close_relationships_details safeguarding_issue_details].freeze

      class << self
        def storable_fields
          FIELDS + %i[has_right_to_work_in_uk has_close_relationships has_safeguarding_issue]
        end

        def unstorable_fields
          %i[declarations_section_completed]
        end

        def load_form(model)
          super.merge(completed_attrs(model, :declarations))
        end
      end
      attr_accessor(*FIELDS)

      attribute :has_right_to_work_in_uk, :boolean
      attribute :has_close_relationships, :boolean
      attribute :has_safeguarding_issue, :boolean

      validates :has_close_relationships, inclusion: { in: [true, false] }, if: -> { declarations_section_completed }
      validates :close_relationships_details, presence: true, if: -> { has_close_relationships && declarations_section_completed }
      validates :has_safeguarding_issue, inclusion: { in: [true, false] }, if: -> { declarations_section_completed }
      validates :safeguarding_issue_details, presence: true, if: -> { has_safeguarding_issue && declarations_section_completed }

      completed_attribute(:declarations)
    end
  end
end
