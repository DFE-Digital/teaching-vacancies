require "rails_helper"

RSpec.describe Jobseekers::JobApplication::EmploymentHistoryForm, type: :model do
  it { is_expected.to validate_inclusion_of(:employment_history_section_completed).in_array([true, false]) }
end
