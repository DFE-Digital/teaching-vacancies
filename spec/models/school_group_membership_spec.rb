require "rails_helper"

RSpec.describe SchoolGroupMembership do
  it { is_expected.to belong_to(:school_group) }
  it { is_expected.to belong_to(:school) }
end
