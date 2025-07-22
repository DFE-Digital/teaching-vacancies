require "rails_helper"

RSpec.describe "publishers/vacancies/review" do
  let(:school) { build_stubbed(:school) }
  let(:vacancy) { build_stubbed(:vacancy, publish_on: publish_date) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }
  let(:step_process) { Publishers::Vacancies::VacancyStepProcess.new(:review, vacancy: vacancy, organisation: school) }

  before do
    allow(view).to receive_messages(vacancy: vacancy_presenter, current_organisation: school, step_process: step_process)

    render
  end

  context "with website applications" do
    let(:vacancy) { build_stubbed(:vacancy, :no_tv_applications) }

    it "doesnt show the document link" do
      expect(rendered).not_to include("Document name")
    end
  end

  context "with email applications" do
    let(:vacancy) { create(:vacancy, :with_application_form) }

    it "shows the document link" do
      expect(rendered).to include("Document name")
    end
  end

  context "with uploaded applications" do
    let(:vacancy) { build_stubbed(:vacancy, :with_uploaded_application_form) }

    it "shows the document link" do
      expect(rendered).to include("Document name")
    end
  end

  context "when the vacancy is published today" do
    let(:publish_date) { Date.current }

    it "shows the immediate publish button" do
      expect(rendered).to include(I18n.t("publishers.vacancies.show.heading_component.action.publish"))
    end
  end

  context "when the vacancy is scheduled for future" do
    let(:publish_date) { Date.current + 2.days }

    it "shows the scheduled publish button" do
      expect(rendered).to include(I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft"))
    end
  end
end
