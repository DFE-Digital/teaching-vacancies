require "rails_helper"

RSpec.describe "Jobseeker profiles", type: :system do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:jobseeker_profile) { create(:jobseeker_profile, :completed) }

  scenario "A publisher can view a jobseeker's profile" do
    login_publisher(publisher:, organisation:)
    visit publishers_jobseeker_profile_path(jobseeker_profile)

    expect(page).to have_content(jobseeker_profile.full_name)
    expect(page).to have_content(jobseeker_profile.jobseeker.email)
    expect(page).to have_content(jobseeker_profile.qualified_teacher_status_year)
    expect(page).to have_content(jobseeker_profile.about_you)
  end
end
