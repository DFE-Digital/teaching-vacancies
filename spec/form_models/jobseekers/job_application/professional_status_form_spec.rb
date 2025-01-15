require "rails_helper"

RSpec.describe Jobseekers::JobApplication::ProfessionalStatusForm, type: :model do
  it { is_expected.to validate_inclusion_of(:qualified_teacher_status).in_array(%w[yes no on_track]) }
  it { is_expected.to validate_inclusion_of(:statutory_induction_complete).in_array(%w[yes no]) }

  context "when qualified_teacher_status is yes" do
    before { allow(subject).to receive(:qualified_teacher_status).and_return("yes") }

    it { is_expected.to validate_numericality_of(:qualified_teacher_status_year).is_less_than_or_equal_to(Time.current.year) }
  end

  describe "statutory_induction_complete_details" do
    let(:valid_attributes) do
      {
        qualified_teacher_status: "yes",
        qualified_teacher_status_year: "2020",
        has_teacher_reference_number: "yes",
        teacher_reference_number: "1234567",
      }
    end

    context "when statutory_induction_complete is yes" do
      it "sets statutory_induction_complete_details to nil" do
        subject = described_class.new(valid_attributes.merge(statutory_induction_complete: "yes", statutory_induction_complete_details: "some info"))
        expect(subject.statutory_induction_complete_details).to be_nil
      end
    end

    context "when statutory_induction_complete is no" do
      it "does not modify statutory_induction_complete_details" do
        subject = described_class.new(valid_attributes.merge(statutory_induction_complete: "no", statutory_induction_complete_details: "some info"))
        expect(subject.statutory_induction_complete_details).to eq "some info"
      end
    end
  end
end
