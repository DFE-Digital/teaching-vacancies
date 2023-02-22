require "rails_helper"

RSpec.describe Jobseekers::Qualifications::Secondary::QualificationResultForm, type: :model do
  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:grade) }
end
