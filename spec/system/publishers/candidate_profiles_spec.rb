require "rails_helper"

RSpec.describe "Candidate profiles", type: :system do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:candidate_profile) { create(:jobseeker_profile) }

  scenario "A publisher can view a candidate's profile" do
    login_publisher(publisher:, organisation:)
    visit publishers_jobseeker_profile_path(candidate_profile)

    expect(page).to have_content(candidate_profile.full_name)
    expect(page).to have_content(candidate_profile.jobseeker.email)
    expect(page).to have_content(candidate_profile.qualified_teacher_status_year)
    expect(page).to have_content(candidate_profile.about_you)
  end
end
