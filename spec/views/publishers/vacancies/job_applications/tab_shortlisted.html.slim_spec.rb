require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/_tab_shortlisted" do
  before do
    render "publishers/vacancies/job_applications/tab_shortlisted",
           tab_name: "shortlisted",
           candidates: { "shortlisted" => candidates.map(&:decorate) },
           form: Publishers::JobApplication::TagForm.new, vacancy: vacancy
  end

  let(:candidates) { build_stubbed_list(:job_application, 2, :status_shortlisted, vacancy:) }
  let(:page) { Capybara.string(rendered) }
  let(:tab_panel) { page.find(".tab-shortlisted") }

  describe "#candidate_name" do
    let(:candidates) { [candidate] }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }
    let(:candidate) { build_stubbed(:job_application, :status_shortlisted, first_name: first_name, last_name: last_name, vacancy:) }

    context "with anonymised vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, anonymise_applications: true) }

      it "has a link to the candidate and includes the anonymised ID" do
        expect(tab_panel.find("a").text).to include(first_name)
        expect(tab_panel).to have_content("TVS-")
      end
    end

    context "with non-anonymised vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, anonymise_applications: false) }

      it "does not show an anonymised id" do
        expect(tab_panel).to have_no_content("TVS-")
      end
    end
  end
end
