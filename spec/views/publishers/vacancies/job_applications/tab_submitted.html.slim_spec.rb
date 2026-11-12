require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/_tab_submitted" do
  before do
    render "publishers/vacancies/job_applications/tab_submitted",
           tab_name: "submitted",
           candidates: { "submitted" => candidates.map(&:decorate) },
           form: Publishers::JobApplication::TagForm.new, vacancy: vacancy
  end

  let(:candidates) { build_stubbed_list(:job_application, 2, :status_submitted, vacancy:) }
  let(:page) { Capybara.string(rendered) }

  let(:tab_panel) { page.find(".tab-submitted") }

  describe "#candidate_name" do
    let(:candidates) { [candidate] }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }
    let(:candidate) { build_stubbed(:job_application, :status_submitted, first_name: first_name, last_name: last_name, vacancy:) }

    context "with anonymised vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, anonymise_applications: true) }

      it "has a link to the candidate in code" do
        expect(tab_panel.find("a").text).to include("TVS-")
      end
    end

    context "with non-anonymised vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, anonymise_applications: false) }

      it "does not show an anonymised id" do
        expect(tab_panel).to have_no_content("TVS-")
      end
    end
  end

  describe "#sort_candidates" do
    let(:vacancy) { build_stubbed(:vacancy) }
    let(:first_candidate) { build_stubbed(:job_application, :status_submitted, submitted_at: Date.new(2025, 1, 3)) }
    let(:nil_candidate) { build_stubbed(:job_application, :status_submitted, submitted_at: nil) }
    let(:early_candidate) { build_stubbed(:job_application, :status_submitted, submitted_at: Date.new(2025, 1, 1)) }
    let(:candidates) { [first_candidate, nil_candidate, early_candidate] }

    let(:result) { page.all(".application-submitted a").map(&:text).reject { |n| ["Pre-interview checks"].include?(n) } }

    it "returns candidates in original order" do
      expect(result).to eq([first_candidate, nil_candidate, early_candidate].map(&:name))
    end
  end
end
