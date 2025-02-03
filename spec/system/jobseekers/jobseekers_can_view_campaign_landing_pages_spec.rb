require "rails_helper"

RSpec.describe "Jobseekers can view the bespoke campaign landing page" do
  let(:school) { create(:school) }

  let!(:recent_part_time_maths_job) do
    create(
      :vacancy,
      :past_publish,
      :no_tv_applications,
      job_roles: %w[teacher],
      working_patterns: %w[part_time],
      publish_on: Date.current - 1,
      job_title: "Maths Teacher",
      subjects: %w[Mathematics],
      organisations: [school],
      phases: %w[secondary],
      expires_at: Date.current + 1,
      geolocation: "POINT(-0.019501 51.504949)",
    )
  end

  let!(:older_part_time_maths_job) do
    create(
      :vacancy,
      :past_publish,
      :no_tv_applications,
      job_roles: %w[teacher],
      working_patterns: %w[part_time],
      publish_on: Date.current - 2,
      job_title: "Maths Teacher",
      subjects: %w[Mathematics],
      organisations: [school],
      phases: %w[secondary],
      expires_at: Date.current + 3,
      geolocation: "POINT(-1.8964 52.4820)",
    )
  end

  it "contains the expected content and vacancies with personalized jobseeker name" do
    visit campaign_landing_page_path(email_name: "John", email_jobrole: "Teacher", email_subject: "Mathematics", utm_content: "FAKE1+CAMPAIGN")

    expect(page).to have_css("h1", text: "John, find the right mathematics fake job for you")

    expect(page).to have_css("#search-results")
    within "#search-results" do
      expect(page).to have_link(recent_part_time_maths_job.job_title, href: job_path(recent_part_time_maths_job))
      expect(page).to have_link(older_part_time_maths_job.job_title, href: job_path(older_part_time_maths_job))
    end
    expect(page).to have_css(".sort-container")
    expect(page).to have_select("Sort by", selected: "Newest job")
  end
end
