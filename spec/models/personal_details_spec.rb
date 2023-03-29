require "rails_helper"

RSpec.describe PersonalDetails do
  describe ".prepare(profile:)" do
    subject(:personal_details) { described_class.prepare(jobseeker_profile:) }
    let(:jobseeker_profile) { create(:jobseeker_profile, personal_details: nil) }
    let(:jobseeker) { jobseeker_profile.jobseeker }

    context "when a personal details record already exists for that profile" do
      let!(:existing_personal_details) { create(:personal_details, jobseeker_profile:) }

      it "returns the existing personal details record" do
        expect(personal_details).to eq(existing_personal_details)
      end

      it "does not set completed steps" do
        expect(personal_details.completed_steps).to eq(existing_personal_details.completed_steps)
      end
    end

    context "when the profile has a previous application" do
      let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:) }

      it "uses the details from the previous application" do
        expect(personal_details.first_name).to eq(previous_application.first_name)
        expect(personal_details.last_name).to eq(previous_application.last_name)
        expect(personal_details.phone_number).to eq(previous_application.phone_number)
        expect(personal_details.right_to_work_in_uk).to eq(previous_application.right_to_work_in_uk == "yes")
      end

      it "sets some steps to completed" do
        expect(personal_details.completed_steps).to include("name", "phone_number", "work")
      end
    end

    context "when the profile has no previous application" do
      it "does not use the details from the previous application" do
        expect(personal_details.first_name).to be_nil
      end

      it "does not set completed steps" do
        expect(personal_details.completed_steps).to be_empty
      end
    end

    describe "marking steps as completed" do
      context "when there's no previous application" do
        it "does not set completed steps" do
          expect(personal_details.completed_steps).to be_empty
        end
      end

      context "when there's an existing profile" do
        before { create(:jobseeker_profile, jobseeker:) }

        it "does not set completed steps" do
          expect(personal_details.completed_steps).to be_empty
        end
      end

      context "when the name step is partially prefilled" do
        before { create(:job_application, :status_submitted, jobseeker:, last_name: nil) }

        it "does not set the step as completed" do
          expect(personal_details.completed_steps).not_to include("name")
        end
      end

      context "when the name step is fully prefilled" do
        before { create(:job_application, :status_submitted, jobseeker:) }

        it "sets the step as completed" do
          expect(personal_details.completed_steps).to include("name")
        end
      end

      context "when the phone number step is fully prefilled" do
        before { create(:job_application, :status_submitted, jobseeker:) }

        it "sets the step as completed" do
          expect(personal_details.completed_steps).to include("phone_number")
        end
      end
    end
  end
end
