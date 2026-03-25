require "rails_helper"

RSpec.describe JobPreferences do
  describe ".prepare(profile:)" do
    subject(:job_preferences) { described_class.prepare(jobseeker_profile:) }
    let(:jobseeker_profile) { create(:jobseeker_profile, job_preferences: nil) }
    let(:jobseeker) { jobseeker_profile.jobseeker }

    context "when a job preferences record already exists for that profile" do
      let!(:existing_job_preferences) { create(:job_preferences, jobseeker_profile:) }

      it "returns the existing job preferences record" do
        expect(job_preferences).to eq(existing_job_preferences)
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

  describe ".migrate_legacy_working_patterns" do
    let!(:pref_a) { create(:job_preferences, working_patterns: %w[term_time flexible part_time]) }
    let!(:pref_b) { create(:job_preferences, working_patterns: %w[flexible full_time]) }
    let!(:pref_c) { create(:job_preferences, working_patterns: %w[term_time]) }

    before do
      create(:job_preferences)
      create(:job_preferences, working_patterns: nil)
      described_class.migrate_legacy_working_patterns
    end

    it "fixes up term time flexible" do
      expect(pref_a.reload.working_patterns).to match_array(%w[full_time part_time])
    end

    it "fixes up flexible full_time" do
      expect(pref_b.reload.working_patterns).to match_array(%w[part_time full_time])
    end

    it "fixes up term_time" do
      expect(pref_c.reload.working_patterns).to match_array(%w[full_time])
    end
  end
end
