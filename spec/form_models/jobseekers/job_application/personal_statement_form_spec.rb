require "rails_helper"

RSpec.describe Jobseekers::JobApplication::PersonalStatementForm, type: :model do
  subject do
    described_class.new(personal_statement_section_completed: true)
  end

  it { is_expected.to validate_presence_of(:personal_statement_richtext) }
end
