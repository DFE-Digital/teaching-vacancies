require "rails_helper"

RSpec.describe Jobseekers::JobApplication::PersonalDetailsForm, type: :model do
  it { is_expected.to validate_presence_of(:first_name) }
end
