require "rails_helper"

RSpec.describe "Using the vacancy facets to search for jobs" do
  before do
    store = MockRedis.new
    store.set(:job_roles, { "teacher" => 1 }.to_json)
    store.set(:subjects, { "Bengali" => 5 }.to_json)
    store.set(:cities, { "London" => 10 }.to_json)
    store.set(:counties, { "Devon" => 15 }.to_json)
    vacancy_facets = VacancyFacets.new(store: store)
    allow(VacancyFacets).to receive(:new).and_return(vacancy_facets)
    visit root_path
  end

  scenario "job role facets count and link are displayed" do
    expect(page).to have_content("Teacher (1)")
    expect(page).to have_link("Teacher", href: jobs_path(job_roles: "teacher"))
  end

  scenario "subject facets count and link are displayed" do
    expect(page).to have_content("Bengali (5)")
    expect(page).to have_link("Bengali", href: jobs_path(keyword: "Bengali"))
  end

  scenario "cities facets count and link are displayed" do
    expect(page).to have_content("London (10)")
    expect(page).to have_link("London", href: location_category_path("London"))
  end

  scenario "counties facets count and link are displayed" do
    expect(page).to have_content("Devon (15)")
    expect(page).to have_link("Devon", href: location_category_path("Devon"))
  end
end
