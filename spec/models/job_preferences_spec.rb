require "rails_helper"

RSpec.describe JobPreferences do
  describe ".prepare(profile:)" do
    subject(:job_preferences) { described_class.prepare(profile:) }
    let(:jobseeker_profile) { create(:jobseeker_profile, job_preferences: nil) }
    let(:profile) { jobseeker_profile }
    let(:jobseeker) { jobseeker_profile.jobseeker }

    context "when a job preferences record already exists for that profile" do
      let!(:existing_job_preferences) { create(:job_preferences, jobseeker_profile:) }

      it "returns the existing job preferences record" do
        expect(job_preferences).to eq(existing_job_preferences)
      end

      it "does not allow modifying the record via the 'before save' callback" do
        found_job_preferences = described_class.prepare(profile:) do |record|
          record.roles << "teacher"
        end

        expect(found_job_preferences.reload.roles).to eq(existing_job_preferences.roles)
      end

      it "does not set completed steps" do
        expect(job_preferences.completed_steps).to eq(existing_job_preferences.completed_steps)
      end
    end

    context "when the profile has a previous application" do
      let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:) }

      it "does not use the details from the previous application" do
        expect(job_preferences.roles).to be_empty
      end

      it "does not set completed steps" do
        expect(job_preferences.completed_steps).to be_empty
      end

      it "allows modifying the record before saving" do
        new_job_preferences = described_class.prepare(profile:) do |record|
          record.roles << "teacher"
        end

        expect(new_job_preferences.reload.roles).to include("teacher")
      end
    end

    context "when the profile has no previous application" do
      it "does not use the details from the previous application" do
        expect(job_preferences.roles).to be_empty
      end

      it "does not set completed steps" do
        expect(job_preferences.completed_steps).to be_empty
      end
    end
  end
end
