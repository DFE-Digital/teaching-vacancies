require "rails_helper"

RSpec.describe "Jobseeker profiles", type: :system do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:jobseeker_profile) { create(:jobseeker_profile, :completed, :with_location_preferences) }

  before do
    jobseeker_profile.job_preferences.update(roles: %w[ teacher headteacher deputy_headteacher assistant_headteacher head_of_year_or_phase head_of_department_or_curriculum teaching_assistant
                                                        higher_level_teaching_assistant education_support sendco other_teaching_support administration_hr_data_and_finance
                                                        catering_cleaning_and_site_management it_support pastoral_health_and_welfare other_leadership other_support ])
  end

  scenario "A publisher can view a jobseeker's profile" do
    login_publisher(publisher:, organisation:)
    visit publishers_jobseeker_profile_path(jobseeker_profile)

    expect(page).to have_content(jobseeker_profile.full_name)
    expect(page).to have_content(jobseeker_profile.jobseeker.email)
    expect(page).to have_content(jobseeker_profile.qualified_teacher_status_year)
    expect(page).to have_content(jobseeker_profile.about_you)
    expect(page).to have_content(jobseeker_profile.job_preferences.subjects.map(&:humanize).join(", "))
    expect(page).to have_content(
      "Teacher, Headteacher, Deputy headteacher, Assistant headteacher, " \
      "Head of year or phase, Head of department or curriculum, " \
      "Teaching assistant, HLTA (higher level teaching assistant), " \
      "Learning support or cover supervisor, SENDCo (special educational needs and disabilities coordinator), " \
      "Other teaching support, Administration, HR, data and finance, " \
      "Catering, cleaning and site management, IT support, " \
      "Pastoral, health and welfare, Other leadership roles, " \
      "Other support roles",
    )
    expect(page).to have_content(jobseeker_profile.employments.first.subjects)
    expect(page).not_to have_content("Location")
  end
end
