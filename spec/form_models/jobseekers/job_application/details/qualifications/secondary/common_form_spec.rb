require "rails_helper"

RSpec.describe Jobseekers::JobApplication::Details::Qualifications::Secondary::CommonForm, type: :model do
  subject { described_class.new(params) }
  let(:params) { {} }

  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:institution) }
  it { is_expected.to validate_presence_of(:year) }

  it_behaves_like "validates year format"

  context "when there is only one subject or grade" do
    let(:params) { { subject1: "Clarinet" } }

    it { is_expected.to validate_presence_of(:subject1) }
    it { is_expected.to validate_presence_of(:grade1) }

    it "does not validate subjects_and_grades_have_counterparts?" do
      expect(subject).not_to receive(:subjects_and_grades_have_counterparts?)

      subject.valid?
    end

    it "calculates the correct number of rows to display" do
      expect(subject.row_count).to eq(1)
    end
  end

  describe "#subjects_and_grades_have_counterparts?" do
    before { subject.valid? }

    context "when there is more than one subject or grade" do
      let(:params) do
        { subject1: "", grade1: "",
          subject2: subject2, grade2: grade2,
          subject9: "Chess", grade9: "Grandmaster" }
      end
      let(:subject2) { "Driving" }
      let(:grade2) { "Pass" }

      it "calculates the correct number of rows to display" do
        expect(subject.row_count).to eq(3)
      end

      context "when all present subjects have a grade and vice versa" do
        it "does not add the counterpart error message to subject1" do
          expect(subject.errors.messages_for(:subject1)).not_to include(I18n.t("qualification_errors.subjects_and_grades_have_counterparts.false"))
        end

        it { is_expected.to validate_presence_of(:subject1) }
        it { is_expected.to validate_presence_of(:grade1) }
      end

      context "when a grade param (for which a subject param exists) is empty" do
        let(:grade2) { "" }

        it "adds the counterpart error message to subject1" do
          expect(subject.errors.messages_for(:subject1)).to include(I18n.t("qualification_errors.subjects_and_grades_have_counterparts.false"))
        end

        it "adds error styling to the whole fieldset without repeating the error message" do
          %i[grade1 subject2 grade2 subject9 grade9].each { |attr| expect(subject.errors.messages_for(attr)).to include("") }
        end

        it { is_expected.not_to validate_presence_of(:subject1) }
        it { is_expected.not_to validate_presence_of(:grade1) }
      end

      context "when a subject param (for which a grade param exists) is empty" do
        let(:subject2) { "" }

        it "adds the counterpart error message to subject1" do
          expect(subject.errors.messages_for(:subject1)).to include(I18n.t("qualification_errors.subjects_and_grades_have_counterparts.false"))
        end

        it "adds error styling to the whole fieldset without repeating the error message" do
          %i[grade1 subject2 grade2 subject9 grade9].each { |attr| expect(subject.errors.messages_for(attr)).to include("") }
        end

        it { is_expected.not_to validate_presence_of(:subject1) }
        it { is_expected.not_to validate_presence_of(:grade1) }
      end
    end
  end
end
