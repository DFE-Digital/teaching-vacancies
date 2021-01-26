require "rails_helper"

RSpec.describe SavedJob, type: :model do
  it { is_expected.to belong_to(:jobseeker) }
  it { is_expected.to belong_to(:vacancy) }
end
