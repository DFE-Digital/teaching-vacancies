require "rails_helper"

RSpec.describe SchoolGroup do
  it { is_expected.to have_many(:school_group_memberships) }
  it { is_expected.to have_many(:schools) }
end
