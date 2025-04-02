require "rails_helper"

RSpec.describe Jobseekers::JobApplication::ProfessionalStatusForm, type: :model do
  describe "validations" do
    subject(:form) { described_class.new(attributes) }

    RSpec.shared_examples "validates teacher reference number format" do
      %w[123456 12345678 123456a 123-456 123-4567].each do |invalid_trn|
        it { is_expected.not_to allow_value(invalid_trn).for(:teacher_reference_number) }
      end
      it { is_expected.to allow_value("1234567").for(:teacher_reference_number) }
    end

    RSpec.shared_examples "allows teacher reference number to be blank" do
      it { is_expected.to allow_value("").for(:teacher_reference_number) }
      it { is_expected.to allow_value(nil).for(:teacher_reference_number) }
    end

    context "when the professional status section is not completed" do
      let(:attributes) { { professional_status_section_completed: false } }

      it { is_expected.not_to validate_presence_of(:qualified_teacher_status) }
      it { is_expected.not_to validate_presence_of(:qualified_teacher_status_year) }
      it { is_expected.not_to validate_presence_of(:teacher_reference_number) }
      it { is_expected.not_to validate_presence_of(:statutory_induction_complete_details) }
      it { is_expected.not_to validate_presence_of(:qts_age_range_and_subject) }
      it { is_expected.not_to validate_presence_of(:qualified_teacher_status_details) }

      include_examples "validates teacher reference number format"
      include_examples "allows teacher reference number to be blank"
    end

    context "when the professional status section is completed" do
      let(:attributes) { { professional_status_section_completed: true } }

      it { is_expected.to validate_inclusion_of(:qualified_teacher_status).in_array(%w[yes no on_track]) }

      context "when qualified_teacher_status is 'yes'" do
        let(:attributes) { super().merge(qualified_teacher_status: "yes") }

        it { is_expected.to validate_numericality_of(:qualified_teacher_status_year).is_less_than_or_equal_to(Time.current.year) }

        it { is_expected.not_to validate_presence_of(:teacher_reference_number) }
      end

      %w[no on_track].each do |status|
        context "when qualified_teacher_status is '#{status}'" do
          let(:attributes) { super().merge(qualified_teacher_status: status) }

          it { is_expected.not_to validate_numericality_of(:qualified_teacher_status_year).is_less_than_or_equal_to(Time.current.year) }
          it { is_expected.not_to validate_presence_of(:teacher_reference_number) }

          include_examples "validates teacher reference number format"
          include_examples "allows teacher reference number to be blank"
        end
      end
    end
  end

  describe "statutory_induction_complete_details" do
    let(:valid_attributes) do
      {
        qualified_teacher_status: "yes",
        qualified_teacher_status_year: "2020",
        teacher_reference_number: "1234567",
      }
    end

    context "when is_statutory_induction_complete is true" do
      it "sets statutory_induction_complete_details to nil" do
        subject = described_class.new(valid_attributes.merge(is_statutory_induction_complete: true, statutory_induction_complete_details: "some info"))
        expect(subject.statutory_induction_complete_details).to be_nil
      end
    end

    context "when is_statutory_induction_complete is false" do
      it "does not modify statutory_induction_complete_details" do
        subject = described_class.new(valid_attributes.merge(is_statutory_induction_complete: false, statutory_induction_complete_details: "some info"))
        expect(subject.statutory_induction_complete_details).to eq "some info"
      end
    end
  end
end
