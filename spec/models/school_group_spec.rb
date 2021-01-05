require "rails_helper"

RSpec.describe SchoolGroup, type: :model do
  it { should have_many(:school_group_memberships) }
  it { should have_many(:schools) }

  it { expect(subject.attributes).to include("gias_data") }
  it { expect(described_class.columns_hash["gias_data"].type).to eq(:json) }
end
