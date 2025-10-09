require "rails_helper"

RSpec.describe "Jobseekers can view intermediary landing pages" do
  scenario "leadership-roles page" do
    visit page_path("leadership-roles")

    expect(page.find("h1")).to have_text("Find your next leadership role with Teaching Vacancies")
    expected_query_params = {
      teaching_job_roles: %w[head_of_year_or_phase head_of_department_or_curriculum assistant_headteacher deputy_headteacher headteacher other_leadership],
      radius: 0,
      sort_by: "publish_on",
    }
    expect(page.find(".hero")).to have_link("Search roles", href: jobs_path(expected_query_params))
    expect(page).to have_text("Support to help you succeed")
    expect(page).to have_text("Related links")
  end
end
