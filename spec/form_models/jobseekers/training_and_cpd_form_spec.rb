require "rails_helper"

RSpec.describe Jobseekers::TrainingAndCpdForm, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:provider) }
  it { is_expected.to validate_presence_of(:year_awarded) }
end
