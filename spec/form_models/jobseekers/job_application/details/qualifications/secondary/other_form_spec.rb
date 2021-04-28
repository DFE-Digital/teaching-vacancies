require "rails_helper"

RSpec.describe Jobseekers::JobApplication::Details::Qualifications::Secondary::OtherForm, type: :model do
  subject { described_class.new(params) }
  let(:params) { {} }

  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:institution) }
  it { is_expected.to validate_presence_of(:year) }

  it_behaves_like "validates year format"

  context "when there is only one subject or grade" do
    let(:params) { { subject1: "Clarinet" }.transform_keys(&:to_s) }

    it { is_expected.to validate_presence_of(:subject1) }
    it { is_expected.to validate_presence_of(:grade1) }

    it "does not validate subjects_and_grades_have_counterparts?" do
      expect(subject).not_to receive(:subjects_and_grades_have_counterparts?)

      subject.valid?
    end
  end

  context "when there is more than one subject or grade" do
    let(:params) { { subject1: "Clarinet", grade1: "A", subject2: "Handbells", grade2: "B" } }

    it "validates subjects_and_grades_have_counterparts?" do
      expect(subject).to receive(:subjects_and_grades_have_counterparts?)

      subject.valid?
    end
  end
end
