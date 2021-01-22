require "rails_helper"

RSpec.describe Jobseekers::JobApplication::PersonalStatementForm, type: :model do
  it { is_expected.to validate_presence_of(:personal_statement) }
end
