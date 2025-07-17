require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe EqualOpportunitiesReport do
  subject { build(:equal_opportunities_report) }

  it { is_expected.to belong_to(:vacancy) }
  it { is_expected.to validate_uniqueness_of(:vacancy) }
end
