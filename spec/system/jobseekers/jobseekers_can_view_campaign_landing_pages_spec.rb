require "rails_helper"

RSpec.describe "Jobseekers can view the bespoke campaign landing page" do
  let(:school) { create(:school) }
  let!(:maths_job1) { create(:vacancy, :past_publish, :no_tv_applications, job_roles: ["teacher"], publish_on: Date.current - 1, job_title: "Maths 1", subjects: %w[Mathematics], organisations: [school], phases: %w[secondary], expires_at: Date.current + 1, geolocation: "POINT(-0.019501 51.504949)") }
  let!(:maths_job2) { create(:vacancy, :past_publish, :no_tv_applications, job_roles: ["teacher"], publish_on: Date.current - 2, job_title: "Maths Teacher 2", subjects: %w[Mathematics], organisations: [school], phases: %w[secondary], expires_at: Date.current + 3, geolocation: "POINT(-1.8964 52.4820)") }

  it "contains the expected content and vacancies with personalized jobseeker name" do
    visit campaign_jobs_path(email_name: "John", email_jobrole: "Teacher", email_subject: "Mathematics")

    expect(page).to have_css("h1", text: "John, find your primary teacher job")

    expect(page).to have_css("#search-results")
    within "#search-results" do
      expect(page).to have_link(maths_job1.job_title, href: job_path(maths_job1))
      expect(page).to have_link(maths_job2.job_title, href: job_path(maths_job2))
    end
    expect(page).to have_css(".sort-container")
    expect(page).to have_select("Sort by", selected: "Newest job")
  end
end
