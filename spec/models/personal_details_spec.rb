require "rails_helper"

RSpec.describe PersonalDetails do
  xdescribe ".prepare(profile:)" do
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

    context "when the jobseeker has a previous draft application" do
      before do
        create(:job_application, :status_draft, jobseeker:, first_name: "karl", last_name: "karlssen", phone_number: "01234567899", has_right_to_work_in_uk: true)
      end

      it "does not use details from draft application" do
        expect(personal_details.first_name).to be_nil
        expect(personal_details.last_name).to be_nil
        expect(personal_details.has_right_to_work_in_uk).to be_nil
      end

      it "does not set steps to completed" do
        expect(personal_details.completed_steps).to be_blank
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
    end
  end
end
