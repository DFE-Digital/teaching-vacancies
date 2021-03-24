require "rails_helper"

RSpec.describe SavedJob do
  it { is_expected.to belong_to(:jobseeker) }
  it { is_expected.to belong_to(:vacancy) }
end
