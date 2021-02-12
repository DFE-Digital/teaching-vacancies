require "rails_helper"

RSpec.describe "Jobseekers can view and visit homepage facets", vcr: { cassette_name: "algoliasearch" } do
  let(:home_page) { PageObjects::Home.new }
  let(:jobs_page) { PageObjects::Vacancy::Index.new }

  # TODO: Instead of stubbing implementation details, we should move towards e.g. VCR in the future
  let(:vacancy_facets) do
    instance_double(
      VacancyFacets,
      job_roles: { "teacher" => 1 },
      subjects: { "Bengali" => 5 },
      cities: { "London" => 10 },
      counties: { "Devon" => 15 },
    )
  end

  before do
    allow(VacancyFacets).to receive(:new).and_return(vacancy_facets)
    home_page.load
  end

  describe "job roles" do
    let(:facet) { home_page.job_roles.facets.first }

    it "has the expected facet" do
      expect(facet.text).to eq("Teacher (1)")
    end

    it "goes to the correct landing page and checks the job roles filter" do
      facet.visit

      expect(current_path).to eq(job_role_path("teacher"))
      expect(jobs_page.filters.teacher).to be_checked
    end
  end

  describe "subjects" do
    let(:facet) { home_page.subjects.facets.first }

    it "has the expected facet" do
      expect(facet.text).to eq("Bengali (5)")
    end

    it "goes to the correct landing page and adds the subject to the keyword field" do
      facet.visit

      expect(current_path).to eq(subject_path("Bengali"))
      expect(jobs_page.filters.keyword.value).to eq("Bengali")
    end
  end

  describe "cities" do
    let!(:london_polygon) { create(:location_polygon, name: "london") }
    let(:facet) { home_page.cities.facets.first }

    it "has the expected facet" do
      expect(facet.text).to eq("London (10)")
    end

    it "goes to the correct landing page and fills the location field" do
      facet.visit

      expect(current_path).to eq(location_path("London"))
      expect(jobs_page.filters.location.value).to eq("London")
    end
  end

  describe "counties" do
    let!(:devon_polygon) { create(:location_polygon, name: "devon") }
    let(:facet) { home_page.counties.facets.first }

    it "has the expected facet" do
      expect(facet.text).to eq("Devon (15)")
    end

    it "goes to the correct landing page and fills the location field" do
      facet.visit

      expect(current_path).to eq(location_path("Devon"))
      expect(jobs_page.filters.location.value).to eq("Devon")
    end
  end
end
