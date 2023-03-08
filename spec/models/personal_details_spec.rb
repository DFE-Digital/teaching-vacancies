require "rails_helper"

RSpec.describe PersonalDetails do
  describe ".prepare(profile:)" do
    subject(:personal_details) { described_class.prepare(profile:) }
    let(:jobseeker_profile) { create(:jobseeker_profile, personal_details: nil) }
    let(:profile) { jobseeker_profile }
    let(:jobseeker) { jobseeker_profile.jobseeker }

    context "when a personal details record already exists for that profile" do
      let!(:existing_personal_details) { create(:personal_details, jobseeker_profile:) }

      it "returns the existing personal details record" do
        expect(personal_details).to eq(existing_personal_details)
      end

      it "does not allow modifying the record via the 'before save' callback" do
        found_personal_details = described_class.prepare(profile:) do |record|
          record.first_name = "Fred"
        end

        expect(found_personal_details.reload.first_name).not_to eq("Fred")
        expect(found_personal_details.reload.first_name).to eq(existing_personal_details.first_name)
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
      end

      it "allows modifying the record before saving" do
        new_personal_details = described_class.prepare(profile:) do |record|
          record.first_name = "Fred"
        end

        expect(new_personal_details.reload.first_name).to eq("Fred")
      end

      it "sets some steps to completed" do
        expect(personal_details.completed_steps).to include("name", "phone_number")
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
  end
end
