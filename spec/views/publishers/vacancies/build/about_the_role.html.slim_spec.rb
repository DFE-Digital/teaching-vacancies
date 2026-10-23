require "rails_helper"

RSpec.describe "publishers/vacancies/build/about_the_role" do
  let(:local_authority) { build_stubbed(:local_authority) }
  let(:publisher) { build_stubbed(:publisher) }
  let(:vacancy) { build_stubbed(:vacancy, organisations: [organisation]) }
  let(:step_process) { Publishers::Vacancies::VacancyStepProcess.new(:about_the_role, vacancy: vacancy, organisation: organisation) }
  let(:form) { Publishers::JobListing::AboutTheRoleForm.new }

  before do
    allow(view).to receive_messages(current_organisation: local_authority, vacancy: vacancy,
                                    back_path: "",
                                    current_step: :about_the_role,
                                    step_process: step_process, form: form, wizard_path: "")
    render
  end

  context "with a college" do
    let(:organisation) { build_stubbed(:college) }

    it "offers college text" do
      expect(rendered).to have_content("Tell jobseekers about your learners and the culture of your college", count: 1)
    end
  end

  context "with a school" do
    let(:organisation) { build_stubbed(:school) }

    it "offers school text" do
      expect(rendered).to have_content("Tell jobseekers about your learners and the culture of your school", count: 1)
      expect(rendered).to have_content(I18n.t("jobs.school_offer.hint"), count: 1)
    end
  end
end
