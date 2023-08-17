require "rails_helper"

RSpec.describe "Inviting Jobseekers to apply for vacancies", type: :system do
  include ActiveJob::TestHelper

  let!(:job_preferences) do
    create(:job_preferences,
           roles: %w[headteacher],
           phases: %w[primary],
           key_stages: %w[ks1 ks2],
           subjects: %w[english maths],
           working_patterns: %w[full_time])
  end
  let!(:location_preference) { create(:job_preferences_location, name: "London", radius: 200, job_preferences: job_preferences) }
  let!(:jobseeker_profile) { create(:jobseeker_profile, :completed, job_preferences:) }

  let!(:organisation) { create(:school, geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(0.2861, 51.7094)) }
  let!(:publisher) { create(:publisher, organisations: [organisation]) }
  let!(:vacancy) do
    create(:vacancy,
           :published,
           organisations: publisher.organisations,
           publisher: publisher,
           job_role: "senior_leader",
           phases: job_preferences.phases,
           key_stages: job_preferences.key_stages,
           subjects: job_preferences.subjects,
           working_patterns: job_preferences.working_patterns)
  end

  let(:location_in_london) { [51.5072, -0.1275] }

  before do
    allow(Geocoding).to receive(:test_coordinates).and_return(location_in_london)
  end

  scenario "A publisher can invite a jobseeker to apply for jobs from the jobseeker profile" do
    pd = jobseeker_profile.personal_details
    profile_name = "#{pd.first_name} #{pd.last_name}"

    login_publisher(publisher:)
    visit root_path
    click_link "Candidate profiles"
    click_link profile_name
    click_link "Invitations to apply"
    click_link "Invite #{profile_name} to apply for a job"
    expect(page).to have_css("h3", text: "Jobs to invite the candidate to apply for")

    check vacancy.job_title
    click_button "Continue"
    expect(page).to have_css("h1", text: "Check details and invite candidate to apply")
    expect(page.find("dt.govuk-summary-list__key", text: "Jobs to invite candidate to apply for"))
      .to have_sibling("dd", text: vacancy.job_title)

    perform_enqueued_jobs do
      click_button "Send invite to apply"
    end
    expect(current_path).to eq(publishers_jobseeker_profile_path(jobseeker_profile))
    expect(page).to have_content("Invited to apply for a job")
    click_link "Invitations to apply"
    within("tbody tr") do
      expect(page).to have_css("td", text: vacancy.job_title)
      expect(page).to have_css("td", text: "#{publisher.given_name} #{publisher.family_name}")
    end

    expect(last_email.to).to eq([jobseeker_profile.email])
    expect(last_email.subject).to eq(I18n.t("publishers.invitations_mailer.invite_to_apply.subject.one"))
  end
end
