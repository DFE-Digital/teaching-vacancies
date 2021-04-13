require "rails_helper"

RSpec.describe EqualOpportunitiesReport do
  it { is_expected.to belong_to(:vacancy) }
end
