require "rails_helper"

RSpec.describe "Jobseekers can view and visit homepage facets", vcr: { cassette_name: "algoliasearch" } do
  # TODO: Instead of stubbing implementation details, we should move towards e.g. VCR in the future
  let(:vacancy_facets) do
    instance_double(
      VacancyFacets,
      additional_job_roles: { "ect_suitable" => 2, "send_responsible" => 3 },
      cities: { "London" => 10 },
      counties: { "Devon" => 15 },
      education_phases: { "middle" => 3 },
      job_roles: { "teacher" => 1 },
      subjects: { "English" => 5 },
    )
  end

  before do
    allow(VacancyFacets).to receive(:new).and_return(vacancy_facets)
    visit root_path
  end

  describe "cities" do
    it "has the expected facet" do
      expect(page).to have_content("London view 10 vacancies listed")
    end

    it "goes to the correct landing page and checks the job roles filter" do
      click_on "London"

      expect(current_path).to eq(location_path("london"))
      expect(page.find("#location-field").value).to eq("London")
    end
  end

  describe "counties" do
    it "has the expected facet" do
      expect(page).to have_content("Devon view 15 vacancies listed")
    end

    it "goes to the correct landing page and fills the location field" do
      click_on "Devon"

      expect(current_path).to eq(location_path("devon"))
      expect(page.find("#location-field").value).to eq("Devon")
    end
  end

  describe "education_phases" do
    it "has the expected facet" do
      expect(page).to have_content("Middle view 3 vacancies listed")
    end

    it "goes to the correct landing page and fills the location field" do
      click_on "Middle"

      expect(current_path).to eq(education_phase_path("middle"))
      expect(page).to have_content(I18n.t("landing_pages.heading", landing_page: "Middle"))
      expect(page.find("#phases-middle-field")).to be_checked
    end
  end

  describe "job roles" do
    it "has the expected facet" do
      expect(page).to have_content("Teacher view 1 vacancies listed")
    end

    it "goes to the correct landing page and checks the job roles filter" do
      click_on "Teacher"

      expect(current_path).to eq(job_role_path("teacher"))
      expect(page).to have_content(I18n.t("landing_pages.heading", landing_page: "Teacher"))
      expect(page.find("#job-roles-teacher-field")).to be_checked
    end
  end

  describe "additional job roles" do
    it "has the expected facets" do
      expect(page).to have_content("Suitable for early career teachers view 2 vacancies listed")
      expect(page).to have_content("SEND responsibilities view 3 vacancies listed")
    end

    it "early career teachers link goes to the correct landing page and checks the job roles filter" do
      click_on "Suitable for early career teachers"

      expect(current_path).to eq(job_role_path("ect-suitable"))
      expect(page.find("#job-roles-ect-suitable-field")).to be_checked
    end

    it "send responsible link goes to the correct landing page and checks the job roles filter" do
      click_on "SEND responsibilities"

      expect(current_path).to eq(job_role_path("send-responsible"))
      expect(page.find("#job-roles-send-responsible-field")).to be_checked
    end
  end

  describe "subjects" do
    it "has the expected facet" do
      expect(page).to have_content("English view 5 vacancies listed")
    end

    it "goes to the correct landing page and checks the job roles filter" do
      click_on "English"

      expect(current_path).to eq(subject_path("english"))
      expect(page).to have_content(I18n.t("landing_pages.heading", landing_page: "English"))
      expect(page.find("#keyword-field").value).to eq("english")
    end
  end
end
