require "rails_helper"

RSpec.describe Publishers::JobListing::WorkingPatternsForm, type: :model do
  it { is_expected.to validate_presence_of(:working_patterns) }
end
