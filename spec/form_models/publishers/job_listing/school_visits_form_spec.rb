require "rails_helper"

RSpec.describe Publishers::JobListing::SchoolVisitsForm, type: :model do
  it { is_expected.to validate_inclusion_of(:school_visits).in_array([true, false, "true", "false"]) }
end
