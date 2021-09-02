require "rails_helper"

RSpec.describe "Jobseekers can view and visit homepage facets", vcr: { cassette_name: "algoliasearch" } do
  # TODO: Instead of stubbing implementation details, we should move towards e.g. VCR in the future
  let(:vacancy_facets) do
    instance_double(
      VacancyFacets,
      job_roles: { "teacher" => 1, "nqt_suitable" => 2, "send_responsible" => 3 },
      subjects: { "Bengali" => 5 },
      cities: { "London" => 10 },
      counties: { "Devon" => 15 },
    )
  end

  before do
    allow(VacancyFacets).to receive(:new).and_return(vacancy_facets)
    visit root_path
  end

  describe "job roles" do
    it "has the expected facet" do
      expect(page).to have_css("div[data-facet-type='job_roles']", text: "Teacher view 1 vacancies listed")
    end

    it "goes to the correct landing page and checks the job roles filter" do
      within "div[data-facet-type='job_roles']", text: "Teacher view 1 vacancies listed" do
        click_on "Teacher"
      end

      expect(current_path).to eq(job_role_path("teacher"))
      expect(page.find("#job-roles-teacher-field")).to be_checked
    end
  end

  describe "additional job roles" do
    it "has the expected facets" do
      expect(page).to have_css("div[data-facet-type='nqt_suitable']", text: "Suitable for early career teachers view 2 vacancies listed")
      expect(page).to have_css("div[data-facet-type='send_responsible']", text: "SEND responsibilities view 3 vacancies listed")
    end

    it "early career teachers link goes to the correct landing page and checks the job roles filter" do
      within "div[data-facet-type='nqt_suitable']", text: "Suitable for early career teachers view 2 vacancies listed" do
        click_on "Suitable for early career teachers"
      end

      expect(current_path).to eq(job_role_path("nqt_suitable"))
      expect(page.find("#job-roles-nqt-suitable-field")).to be_checked
    end

    it "send responsible link goes to the correct landing page and checks the job roles filter" do
      within "div[data-facet-type='send_responsible']", text: "SEND responsibilities view 3 vacancies listed" do
        click_on "SEND responsibilities"
      end

      expect(current_path).to eq(job_role_path("send_responsible"))
      expect(page.find("#job-roles-send-responsible-field")).to be_checked
    end
  end

  describe "subjects" do
    it "has the expected facet" do
      expect(page).to have_css("div[data-facet-type='subjects']", text: "Bengali view 5 vacancies listed")
    end

    it "goes to the correct landing page and checks the job roles filter" do
      within "div[data-facet-type='subjects']", text: "Bengali view 5 vacancies listed" do
        click_on "Bengali"
      end

      expect(current_path).to eq(subject_path("Bengali"))
      expect(page.find("#keyword-field").value).to eq("Bengali")
    end
  end

  describe "cities" do
    it "has the expected facet" do
      expect(page).to have_css("div[data-facet-type='cities']", text: "London view 10 vacancies listed")
    end

    it "goes to the correct landing page and checks the job roles filter" do
      within "div[data-facet-type='cities']", text: "London view 10 vacancies listed" do
        click_on "London"
      end

      expect(current_path).to eq(location_path("London"))
      expect(page.find("#location-field").value).to eq("London")
    end
  end

  describe "counties" do
    it "has the expected facet" do
      expect(page).to have_css("div[data-facet-type='counties']", text: "Devon view 15 vacancies listed")
    end

    it "goes to the correct landing page and fills the location field" do
      within "div[data-facet-type='counties']", text: "Devon view 15 vacancies listed" do
        click_on "Devon"
      end

      expect(current_path).to eq(location_path("Devon"))
      expect(page.find("#location-field").value).to eq("Devon")
    end
  end
end
