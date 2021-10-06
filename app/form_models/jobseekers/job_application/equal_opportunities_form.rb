class Jobseekers::JobApplication::EqualOpportunitiesForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[disability age gender gender_description orientation orientation_description ethnicity ethnicity_description religion religion_description]
  end
  attr_accessor(*fields)

  validates :disability, inclusion: { in: %w[no prefer_not_to_say yes] }
  validates :age, inclusion: { in: %w[under_twenty_five twenty_five_to_twenty_nine thirty_to_thirty_nine forty_to_forty_nine fifty_to_fifty_nine sixty_and_over prefer_not_to_say] }
  validates :gender, inclusion: { in: %w[man other prefer_not_to_say woman] }
  validates :orientation, inclusion: { in: %w[bisexual gay_or_lesbian heterosexual other prefer_not_to_say] }
  validates :ethnicity, inclusion: { in: %w[asian black mixed other prefer_not_to_say white] }
  validates :religion, inclusion: { in: %w[buddhist christian hindu jewish muslim none other prefer_not_to_say sikh] }
end
