require "rails_helper"

RSpec.describe Jobseekers::JobApplication::EqualOpportunitiesForm, type: :model do
  it { is_expected.to validate_inclusion_of(:disability).in_array(%w[no prefer_not_to_say yes]) }
  it { is_expected.to validate_inclusion_of(:age).in_array(%w[under_twenty_five twenty_five_to_twenty_nine thirty_to_thirty_nine forty_to_forty_nine fifty_to_fifty_nine sixty_and_over prefer_not_to_say]) }
  it { is_expected.to validate_inclusion_of(:gender).in_array(%w[man other prefer_not_to_say woman]) }
  it { is_expected.to validate_inclusion_of(:orientation).in_array(%w[bisexual gay_or_lesbian heterosexual other prefer_not_to_say]) }
  it { is_expected.to validate_inclusion_of(:ethnicity).in_array(%w[asian black mixed other prefer_not_to_say white]) }
  it { is_expected.to validate_inclusion_of(:religion).in_array(%w[buddhist christian hindu jewish muslim none other prefer_not_to_say sikh]) }
end
