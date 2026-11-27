require "rails_helper"

RSpec.describe "publishers/vacancies/build/school_visits" do
  let(:local_authority) { build_stubbed(:local_authority) }
  let(:publisher) { build_stubbed(:publisher) }
  let(:vacancy) { build_stubbed(:vacancy, organisations: [organisation]) }
  let(:step_process) { Publishers::Vacancies::VacancyStepProcess.new(:school_visits, vacancy: vacancy, organisation: organisation) }
  let(:form) { Publishers::JobListing::SchoolVisitsForm.new }

  before do
    allow(view).to receive_messages(current_organisation: local_authority, vacancy: vacancy,
                                    back_path: "",
                                    step_process: step_process, wizard_path: "")
    assign(:form, form)
    render
  end

  context "with a school" do
    let(:organisation) { build_stubbed(:school) }

    it "offers school visits" do
      expect(rendered).to have_content("school visits")
    end
  end
end
