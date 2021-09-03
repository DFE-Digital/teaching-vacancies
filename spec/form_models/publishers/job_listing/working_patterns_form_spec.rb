require "rails_helper"

RSpec.describe Publishers::JobListing::WorkingPatternsForm, type: :model do
  it { is_expected.to validate_presence_of(:working_patterns) }
  it { is_expected.to validate_inclusion_of(:working_patterns).in_array(Vacancy.working_patterns.keys) }
end
