require "rails_helper"

RSpec.describe "publishers/jobseeker_profiles/show" do
  let(:organisation) { build_stubbed(:school) }
  let(:employment) { build_stubbed(:employment) }
  let(:jobseeker_profile) do
    build_stubbed(:jobseeker_profile, :with_location_preferences,
                  personal_details: build(:personal_details),
                  qualifications: [build_stubbed(:qualification)],
                  employments: [build_stubbed(:employment)],
                  training_and_cpds: [build_stubbed(:training_and_cpd)],
                  professional_body_memberships: [build_stubbed(:professional_body_membership)],
                  job_preferences: build_stubbed(:job_preferences, roles: %w[ teacher
                                                                              headteacher
                                                                              deputy_headteacher
                                                                              assistant_headteacher
                                                                              head_of_year_or_phase
                                                                              head_of_department_or_curriculum
                                                                              teaching_assistant
                                                                              higher_level_teaching_assistant
                                                                              education_support
                                                                              sendco
                                                                              administration_hr_data_and_finance
                                                                              catering_cleaning_and_site_management
                                                                              it_support
                                                                              pastoral_health_and_welfare
                                                                              other_leadership
                                                                              other_support
                                                                              senior_leader
                                                                              middle_leader]))
  end

  before do
    assign(:profile, jobseeker_profile)
    assign(:current_organisation, organisation)
    render
  end

  scenario "A publisher can view a jobseeker's profile" do
    expect(rendered).to have_content(jobseeker_profile.full_name)
    expect(rendered).to have_content(jobseeker_profile.jobseeker.email)
    expect(rendered).to have_content(jobseeker_profile.qualified_teacher_status_year)
    expect(rendered).to have_content(jobseeker_profile.about_you)
    expect(rendered).to have_content(jobseeker_profile.job_preferences.subjects.map(&:humanize).join(", "))
    expect(rendered).to have_content(
      "Teacher, Headteacher, Deputy headteacher, Assistant headteacher, " \
        "Head of year or phase, Head of department or curriculum, " \
        "Teaching assistant, HLTA (higher level teaching assistant), " \
        "Learning support or cover supervisor, SENDCo (special educational needs and disabilities coordinator), " \
        "Administration, HR, data and finance, " \
        "Catering, cleaning and site management, IT support, " \
        "Pastoral, health and welfare, Other leadership roles, " \
        "Other support roles, Senior leader, Middle leader",
    )
    expect(rendered).to have_content(jobseeker_profile.employments.first.subjects)
    expect(rendered).to have_no_content("Location")
    expect(rendered).to have_content(jobseeker_profile.training_and_cpds.first.name)
    expect(rendered).to have_content(jobseeker_profile.training_and_cpds.first.provider)
    expect(rendered).to have_content(jobseeker_profile.training_and_cpds.first.grade)
    expect(rendered).to have_content(jobseeker_profile.training_and_cpds.first.year_awarded)
    expect(rendered).to have_content(jobseeker_profile.job_preferences.working_pattern_details)
    expect(rendered).to have_content(jobseeker_profile.professional_body_memberships.first.name)
    expect(rendered).to have_content(jobseeker_profile.professional_body_memberships.first.membership_type)
    expect(rendered).to have_content(jobseeker_profile.professional_body_memberships.first.membership_number)
    expect(rendered).to have_content(jobseeker_profile.professional_body_memberships.first.year_membership_obtained)
  end

  scenario "A publisher can contact the jobseeker from their profile" do
    expect(rendered).to have_link(jobseeker_profile.email, href: "mailto:#{jobseeker_profile.email}")
  end

  context "when jobseeker has a current role" do
    let(:current_employment) { create(:employment, :jobseeker_profile_employment, job_title: "Mathematics Teacher", is_current_role: true, started_on: 1.year.ago, ended_on: nil) }
    let(:previous_employment) { create(:employment, :jobseeker_profile_employment, job_title: "Science Teacher", is_current_role: false, started_on: 3.years.ago, ended_on: 2.years.ago) }
    let(:jobseeker_profile) do
      create(:jobseeker_profile, :with_personal_details,
             employments: [current_employment, previous_employment],
             job_preferences: create(:job_preferences))
    end

    scenario "displays the current job title even when previous roles exist" do
      expect(rendered).to have_content("Mathematics Teacher")
      expect(rendered).to have_no_content("Previously Mathematics Teacher")
      expect(rendered).to have_no_content("Previously Science Teacher")
    end
  end

  context "when jobseeker has a previous role but no current role" do
    let(:previous_employment) { create(:employment, :jobseeker_profile_employment, job_title: "Science Teacher", is_current_role: false, started_on: 2.years.ago, ended_on: 1.year.ago) }
    let(:jobseeker_profile) do
      create(:jobseeker_profile, :with_personal_details,
             employments: [previous_employment],
             job_preferences: create(:job_preferences))
    end

    scenario "displays the previous job title with 'Previously' prefix" do
      expect(rendered).to have_content("Previously Science Teacher")
    end
  end

  context "when jobseeker has no employment history" do
    let(:jobseeker_profile) do
      create(:jobseeker_profile, :with_personal_details,
             employments: [],
             job_preferences: create(:job_preferences))
    end

    scenario "does not display any job title" do
      expect(rendered).to have_no_content("Previously")
      expect(rendered).to have_no_content("Current role")
    end
  end
end
