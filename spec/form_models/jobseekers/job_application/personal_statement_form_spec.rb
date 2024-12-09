require "rails_helper"

RSpec.describe Jobseekers::JobApplication::PersonalStatementForm, type: :model do
  subject {
    Jobseekers::JobApplication::PersonalStatementForm.new(personal_statement_section_completed: true)
  }

  it { is_expected.to validate_presence_of(:personal_statement) }
end
