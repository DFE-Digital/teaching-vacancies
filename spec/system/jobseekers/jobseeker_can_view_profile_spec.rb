require "rails_helper"

RSpec.describe "Jobseeker viewing their profile for the first time" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  it "successfully initializes the profile and its nested associations without a NotNullViolation crash" do
    expect(jobseeker.jobseeker_profile).to be_nil

    visit jobseekers_profile_path

    expect(page).to have_current_path(jobseekers_profile_path)

    profile = jobseeker.reload.jobseeker_profile
    expect(profile).to be_present
    expect(profile.job_preferences).to be_present
    expect(profile.personal_details).to be_present

    expect(profile.job_preferences.jobseeker_profile_id).to eq(profile.id)
  end
end
