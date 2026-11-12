require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/_tab_unsuccessful" do
  before do
    render "publishers/vacancies/job_applications/tab_unsuccessful",
           tab_name: "unsuccessful",
           candidates: { "unsuccessful" => unsuccessful_candidates.map(&:decorate),
                         "withdrawn" => withdrawn_candidates.map(&:decorate),
                         "rejected" => rejected_candidates.map(&:decorate) },
           form: Publishers::JobApplication::TagForm.new, vacancy: vacancy
  end

  let(:vacancy) { build_stubbed(:vacancy) }
  let(:unsuccessful_candidates) { build_stubbed_list(:job_application, 2, :status_unsuccessful, vacancy:) }
  let(:rejected_candidates) { build_stubbed_list(:job_application, 2, :status_rejected, vacancy:) }
  let(:page) { Capybara.string(rendered) }

  describe "#candidate_name" do
    let(:withdrawn_candidates) { [candidate] }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }

    context "with a withdrawn candidate" do
      let(:tab_panel) { page.find(".tab-unsuccessful") }

      let(:candidate) { build_stubbed(:job_application, :status_withdrawn, first_name: first_name, last_name: last_name, vacancy:) }

      it "does not link to the candidate" do
        expect(tab_panel.all("a").map(&:text)).to match_array(unsuccessful_candidates.map(&:name))
      end
    end
  end
end
