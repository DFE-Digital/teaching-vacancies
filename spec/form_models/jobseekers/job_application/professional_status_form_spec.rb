require "rails_helper"

RSpec.describe Jobseekers::JobApplication::ProfessionalStatusForm, type: :model do
  subject do
    described_class.new(professional_status_section_completed: true)
  end

  it { is_expected.to validate_inclusion_of(:qualified_teacher_status).in_array(%w[yes no on_track]) }
  it { is_expected.to validate_inclusion_of(:statutory_induction_complete).in_array(%w[yes no]) }

  context "when qualified_teacher_status is yes" do
    before { allow(subject).to receive(:qualified_teacher_status).and_return("yes") }

    it { is_expected.to validate_numericality_of(:qualified_teacher_status_year).is_less_than_or_equal_to(Time.current.year) }
  end

  describe "teacher reference information" do
    subject(:form) { described_class.new(attributes) }

    context "with TRI attributes explicitly provided during the initialisation" do
      let(:attributes) { { teacher_reference_number: "1234567", has_teacher_reference_number: "yes" } }

      it "sets the TRI attributes" do
        expect(form).to have_attributes(teacher_reference_number: "1234567",
                                        has_teacher_reference_number: "yes")
      end

      context "when a profile with different TRI attributes is also provided" do
        let(:profile) do
          instance_double(JobseekerProfile, teacher_reference_number: "7654321", has_teacher_reference_number: "yes")
        end
        let(:attributes) { super().merge(jobseeker_profile: profile) }

        it "sets the explicitly provided TRI attributes over the profile attributes" do
          expect(form).to have_attributes(teacher_reference_number: "1234567",
                                          has_teacher_reference_number: "yes")
        end
      end
    end

    context "when no TRI attributes are provided" do
      let(:attributes) { {} }

      it "does not set the TRI attributes" do
        expect(form).to have_attributes(teacher_reference_number: nil,
                                        has_teacher_reference_number: nil)
      end

      context "with a jobseeker profile" do
        let(:attributes) { { jobseeker_profile: profile } }

        context "with TRI values" do
          let(:profile) do
            instance_double(JobseekerProfile, teacher_reference_number: "7654321", has_teacher_reference_number: "yes")
          end

          it "sets the teacher reference number and has_teacher_reference_number from the profile" do
            expect(form).to have_attributes(teacher_reference_number: "7654321",
                                            has_teacher_reference_number: "yes")
          end
        end

        context "without TRI values" do
          let(:profile) do
            instance_double(JobseekerProfile, teacher_reference_number: nil, has_teacher_reference_number: nil)
          end

          it "does not set the TRI attributes" do
            expect(form).to have_attributes(teacher_reference_number: nil,
                                            has_teacher_reference_number: nil)
          end
        end

        context "when explicitly stating no teacher reference number is provided" do
          let(:profile) do
            instance_double(JobseekerProfile, teacher_reference_number: nil, has_teacher_reference_number: "no")
          end

          it "sets the has_teacher_reference_number from the profile" do
            expect(form).to have_attributes(teacher_reference_number: nil,
                                            has_teacher_reference_number: "no")
          end
        end
      end
    end
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
