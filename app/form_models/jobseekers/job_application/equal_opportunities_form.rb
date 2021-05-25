class Jobseekers::JobApplication::EqualOpportunitiesForm
  include ActiveModel::Model

  ATTRIBUTES = %i[disability age gender gender_description orientation orientation_description
                  ethnicity ethnicity_description religion religion_description].freeze

  attr_accessor(*ATTRIBUTES)

  validates :disability, inclusion: { in: %w[no prefer_not_to_say yes] }
  validates :age, inclusion: { in: %w[under_25 twenty_five_to_twenty_nine thirty_to_thirty_nine forty_to_forty_nine fifty_to_fifty_nine sixty_and_over prefer_not_to_say] }
  validates :gender, inclusion: { in: %w[man other prefer_not_to_say woman] }
  validates :orientation, inclusion: { in: %w[bisexual gay_or_lesbian heterosexual other prefer_not_to_say] }
  validates :ethnicity, inclusion: { in: %w[asian black mixed other prefer_not_to_say white] }
  validates :religion, inclusion: { in: %w[buddhist christian hindu jewish muslim none other prefer_not_to_say sikh] }

  validates :gender_description, presence: true, if: -> { gender == "other" }
  validates :orientation_description, presence: true, if: -> { orientation == "other" }
  validates :ethnicity_description, presence: true, if: -> { ethnicity == "other" }
  validates :religion_description, presence: true, if: -> { religion == "other" }
end
