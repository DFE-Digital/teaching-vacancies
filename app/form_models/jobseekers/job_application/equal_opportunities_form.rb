class Jobseekers::JobApplication::EqualOpportunitiesForm
  include ActiveModel::Model

  attr_accessor :disability, :gender, :gender_description, :orientation, :orientation_description,
                :ethnicity, :ethnicity_description, :religion, :religion_description

  validates :disability, inclusion: { in: %w[no prefer_not_to_say yes] }
  validates :gender, inclusion: { in: %w[man other prefer_not_to_say woman] }
  validates :orientation, inclusion: { in: %w[bisexual gay_or_lesbian heterosexual other prefer_not_to_say] }
  validates :ethnicity, inclusion: { in: %w[asian black mixed other prefer_not_to_say white] }
  validates :religion, inclusion: { in: %w[buddhist christian hindu jewish muslim none other prefer_not_to_say sikh] }

  validates :gender_description, presence: true, if: -> { gender == "other" }
  validates :orientation_description, presence: true, if: -> { orientation == "other" }
  validates :ethnicity_description, presence: true, if: -> { ethnicity == "other" }
  validates :religion_description, presence: true, if: -> { religion == "other" }
end
