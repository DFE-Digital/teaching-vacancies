class Jobseekers::JobApplication::EqualOpportunitiesForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  FIELDS = %i[disability age gender gender_description orientation orientation_description ethnicity ethnicity_description religion religion_description].freeze

  class << self
    def fields
      FIELDS + [:equal_opportunities_section_completed]
    end

    def unstorable_fields
      %i[equal_opportunities_section_completed]
    end

    def load_form(model)
      new_attrs = {}
      if model.completed_steps.include?("equal_opportunities")
        new_attrs[:equal_opportunities_section_completed] = true
      elsif model.in_progress_steps.include?("equal_opportunities")
        new_attrs[:equal_opportunities_section_completed] = false
      end
      load_form_attributes(model.attributes.merge(new_attrs))
    end
  end
  attr_accessor(*FIELDS)

  attribute :equal_opportunities_section_completed, :boolean

  validates :disability, inclusion: { in: %w[no prefer_not_to_say yes] }, if: -> { equal_opportunities_section_completed }
  validates :age, inclusion: { in: %w[under_twenty_five twenty_five_to_twenty_nine thirty_to_thirty_nine forty_to_forty_nine fifty_to_fifty_nine sixty_and_over prefer_not_to_say] }, if: -> { equal_opportunities_section_completed }
  validates :gender, inclusion: { in: %w[man other prefer_not_to_say woman] }, if: -> { equal_opportunities_section_completed }
  validates :orientation, inclusion: { in: %w[bisexual gay_or_lesbian heterosexual other prefer_not_to_say] }, if: -> { equal_opportunities_section_completed }
  validates :ethnicity, inclusion: { in: %w[asian black mixed other prefer_not_to_say white] }, if: -> { equal_opportunities_section_completed }
  validates :religion, inclusion: { in: %w[buddhist christian hindu jewish muslim none other prefer_not_to_say sikh] }, if: -> { equal_opportunities_section_completed }

  validates :equal_opportunities_section_completed, inclusion: { in: [true, false], allow_nil: false }
end
