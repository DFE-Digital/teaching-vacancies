require "rails_helper"

RSpec.describe Publishers::JobListing::EducationPhasesForm, type: :model do
  it { is_expected.to validate_presence_of(:phases) }

  it { is_expected.to validate_inclusion_of(:phases).in_array(Vacancy.phases.keys) }
end
