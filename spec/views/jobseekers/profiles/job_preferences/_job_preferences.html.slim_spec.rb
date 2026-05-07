require "rails_helper"

RSpec.describe "jobseekers/profiles/job_preferences/_job_preferences" do
  let(:profile) { build_stubbed(:jobseeker_profile, job_preferences:) }

  before { render partial: "jobseekers/profiles/job_preferences/job_preferences", locals: { profile: } }

  context "when subjects is nil but the step is marked as completed" do
    let(:job_preferences) do
      build_stubbed(:job_preferences,
                    subjects: nil,
                    completed_steps: { "subjects" => "completed" })
    end

    it "renders without error" do
      expect(rendered).to have_content("Subjects")
    end
  end

  context "when subjects is an empty array but the step is marked as completed" do
    let(:job_preferences) do
      build_stubbed(:job_preferences,
                    subjects: [],
                    completed_steps: { "subjects" => "completed" })
    end

    it "renders without error and shows blank text" do
      expect(rendered).to have_content("No subject preference chosen")
    end
  end

  context "when there are multiple locations" do
    let(:job_preferences) do
      prefs = create(:job_preferences)
      create(:job_preferences_location, name: "London", radius: 10, job_preferences: prefs)
      create(:job_preferences_location, name: "Bristol", radius: 25, job_preferences: prefs)
      prefs.reload
    end
    let(:profile) { build_stubbed(:jobseeker_profile, job_preferences:) }

    it "renders each location separated by a line break" do
      expect(rendered).to match(/London.*<br>.*Bristol/m)
    end
  end
end
