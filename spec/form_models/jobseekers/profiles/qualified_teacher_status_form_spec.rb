require "rails_helper"

module Jobseekers
  module Profiles
    RSpec.describe QualifiedTeacherStatusForm, type: :model do
      describe "validations" do
        subject(:form) { described_class.new(attributes) }

        let(:current_year) { Time.current.year }
        let(:attributes) { {} }

        context "when is_qualified_teacher_status is true" do
          let(:attributes) do
            { qualified_teacher_status: "yes",
              qualified_teacher_status_year: current_year,
              teacher_reference_number: "1234567",
              is_statutory_induction_complete: true }
          end

          it { is_expected.to validate_inclusion_of(:qualified_teacher_status).in_array(%w[yes no on_track non_teacher]) }
          it { is_expected.to validate_numericality_of(:qualified_teacher_status_year).is_less_than_or_equal_to(current_year) }
          it { is_expected.to validate_presence_of(:teacher_reference_number) }
          it { is_expected.to allow_value("1234567").for(:teacher_reference_number) }
          it { is_expected.not_to allow_value("12345").for(:teacher_reference_number) }
          it { is_expected.to validate_inclusion_of(:has_teacher_reference_number).in_array([true]) }
        end

        context "when qualified_teacher_status is 'no'" do
          let(:attributes) { { qualified_teacher_status: "no" } }

          it { is_expected.to allow_value("1234567").for(:teacher_reference_number) }
        end

        context "when qualified_teacher_status is 'on_track'" do
          let(:attributes) { { qualified_teacher_status: "on_track" } }

          it { is_expected.to allow_value("1234567").for(:teacher_reference_number) }
        end
      end

      describe "#load_form_from_model" do
        subject(:form) { described_class.load_form_from_model(profile).has_teacher_reference_number }

        context "when TRN is unknown" do
          let(:profile) { build(:jobseeker_profile, teacher_reference_number: nil) }

          it { is_expected.to be_nil }
        end

        context "when TRN is blank" do
          let(:profile) { build(:jobseeker_profile, teacher_reference_number: "") }

          it { is_expected.to be(false) }
        end

        context "when TRN is set" do
          let(:profile) { build(:jobseeker_profile, :with_trn) }

          it { is_expected.to be(true) }
        end
      end
    end
  end
end
