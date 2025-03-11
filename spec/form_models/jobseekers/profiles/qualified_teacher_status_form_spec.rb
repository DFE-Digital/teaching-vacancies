require "rails_helper"

module Jobseekers
  module Profiles
    RSpec.describe QualifiedTeacherStatusForm, type: :model do
      subject(:form) { described_class.new(attributes) }

      let(:current_year) { Time.current.year }
      let(:attributes) { {} }

      describe "validations" do
        context "when is_qualified_teacher_status is true" do
          let(:attributes) do
            { qualified_teacher_status: "yes",
              qualified_teacher_status_year: current_year,
              teacher_reference_number: "1234567",
              has_teacher_reference_number: "yes",
              is_statutory_induction_complete: true }
          end

          it { is_expected.to validate_inclusion_of(:qualified_teacher_status).in_array(%w[yes no on_track non_teacher]) }
          it { is_expected.to validate_numericality_of(:qualified_teacher_status_year).is_less_than_or_equal_to(current_year) }
          it { is_expected.to validate_presence_of(:teacher_reference_number) }
          it { is_expected.to allow_value("1234567").for(:teacher_reference_number) }
          it { is_expected.not_to allow_value("12345").for(:teacher_reference_number) }
          it { is_expected.to validate_inclusion_of(:has_teacher_reference_number).in_array(%w[yes]) }
        end

        context "when qualified_teacher_status is 'no'" do
          let(:attributes) { { qualified_teacher_status: "no", has_teacher_reference_number: "no" } }

          it { is_expected.to allow_value("1234567").for(:teacher_reference_number) }
          it { is_expected.to validate_inclusion_of(:has_teacher_reference_number).in_array(%w[yes no]) }
        end

        context "when qualified_teacher_status is 'on_track'" do
          let(:attributes) { { qualified_teacher_status: "on_track", has_teacher_reference_number: "yes" } }

          it { is_expected.to validate_inclusion_of(:has_teacher_reference_number).in_array(%w[yes no]) }
          it { is_expected.to allow_value("1234567").for(:teacher_reference_number) }
        end
      end

      describe "#updated_teacher_reference_number" do
        context "when has_teacher_reference_number is 'yes'" do
          let(:attributes) { { has_teacher_reference_number: "yes", teacher_reference_number: "1234567" } }

          it "returns the teacher reference number" do
            expect(form.updated_teacher_reference_number).to eq("1234567")
          end
        end

        context "when has_teacher_reference_number is 'no'" do
          let(:attributes) { { has_teacher_reference_number: "no" } }

          it "returns nil" do
            expect(form.updated_teacher_reference_number).to be_nil
          end
        end
      end

      context "when statutory_induction_complete is yes" do
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
            subject = described_class.new(valid_attributes.merge(is_statutory_induction_complete: true, statutory_induction_complete_details: "some info"))
            expect(subject.statutory_induction_complete_details).to be_nil
          end
        end

        context "when statutory_induction_complete is no" do
          it "does not modify statutory_induction_complete_details" do
            subject = described_class.new(valid_attributes.merge(is_statutory_induction_complete: false, statutory_induction_complete_details: "some info"))
            expect(subject.statutory_induction_complete_details).to eq "some info"
          end
        end
      end
    end
  end
end
