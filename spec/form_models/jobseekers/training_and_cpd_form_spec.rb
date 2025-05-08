require "rails_helper"

RSpec.describe Jobseekers::TrainingAndCpdForm, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.not_to validate_presence_of(:provider) }
  it { is_expected.to validate_presence_of(:year_awarded) }
  it { is_expected.not_to validate_presence_of(:course_length) }
end
