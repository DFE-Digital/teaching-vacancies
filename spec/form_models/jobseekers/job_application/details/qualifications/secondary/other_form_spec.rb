require "rails_helper"

RSpec.describe Jobseekers::JobApplication::Details::Qualifications::Secondary::OtherForm, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:institution) }
  it { is_expected.to validate_presence_of(:year) }

  it_behaves_like "validates year format"

  describe "#subject_and_grade_correspond?" do
    # TODO: Add test when functionality is finished
  end
end
