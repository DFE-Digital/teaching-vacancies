RSpec.describe Jobseekers::JobApplication::Details::Qualifications::Secondary::CommonForm, type: :model do
  subject { described_class.new(params) }
  let(:params) { {} }

  it { is_expected.to validate_presence_of(:institution) }
  it { is_expected.to validate_presence_of(:year) }

  it_behaves_like "validates year format"

  describe "#subject_and_grade_correspond?" do
    # TODO: Add test when functionality is finished
  end
end
