require "rails_helper"

RSpec.describe Jobseekers::JobApplication::QualificationsForm, type: :model do
  it { is_expected.to validate_presence_of(:qualifications_section_completed) }
end
