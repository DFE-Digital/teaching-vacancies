require "rails_helper"

RSpec.describe Jobseekers::JobApplication::EmploymentHistoryForm, type: :model do
  it { is_expected.to validate_inclusion_of(:gaps_in_employment).in_array(%w[yes no]) }
end
