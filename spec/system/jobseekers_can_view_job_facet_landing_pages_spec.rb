require "rails_helper"

RSpec.describe "Jobseekers can view job facet landing pages" do
  let(:home_page) { PageObjects::Home.new }
  let(:jobs_page) { PageObjects::Vacancy::Index.new }

  before do
    store = MockRedis.new
    store.set(:job_roles, { teacher: 1 }.to_json)
    store.set(:subjects, { Bengali: 5 }.to_json)
    store.set(:cities, { London: 10 }.to_json)
    store.set(:counties, { Devon: 15 }.to_json)
    vacancy_facets = VacancyFacets.new(store: store)
    allow(VacancyFacets).to receive(:new).and_return(vacancy_facets)
    home_page.load
  end

  describe "job roles" do
    it "goes to the correct landing page and checks the job roles filter" do
      home_page.job_roles.go_to("Teacher")

      expect(current_path).to eq(job_role_path("teacher"))
      expect(jobs_page.filters.teacher).to be_checked
    end
  end

  describe "subjects" do
    it "goes to the correct landing page and adds the subject to the keyword field" do
      home_page.subjects.go_to("Bengali")

      expect(current_path).to eq(subject_path("Bengali"))
      expect(jobs_page.filters.keyword.value).to eq("Bengali")
    end
  end

  describe "locations" do
    let!(:london_polygon) { create(:location_polygon, name: "london") }
    let!(:devon_polygon) { create(:location_polygon, name: "devon") }

    it "goes to the correct landing page and fills the location field" do
      home_page.cities.go_to("London")

      expect(current_path).to eq(location_path("London"))
      expect(jobs_page.filters.location.value).to eq("London")
    end

    it "goes to the correct landing page and fills the location field" do
      home_page.counties.go_to("Devon")

      expect(current_path).to eq(location_path("Devon"))
      expect(jobs_page.filters.location.value).to eq("Devon")
    end
  end
end
