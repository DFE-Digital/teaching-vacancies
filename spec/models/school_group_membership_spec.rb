require "rails_helper"

RSpec.describe SchoolGroupMembership, type: :model do
  it { should belong_to(:school_group) }
  it { should belong_to(:school) }
end
