require "rails_helper"

RSpec.describe "publishers/vacancies/review" do
  let(:school) { build_stubbed(:school) }
  let(:vacancy_presenter) { vacancy.decorate }
  let(:step_process) { Publishers::Vacancies::VacancyStepProcess.new(:review, vacancy: vacancy, organisation: school) }

  before do
    assign :step_process, step_process
    allow(view).to receive_messages(vacancy: vacancy_presenter, current_organisation: school)

    render
  end

  context "with website applications" do
    let(:vacancy) { build_stubbed(:draft_vacancy, :apply_via_website, organisations: [organisation]) }
    let(:application_type) { "Other" }
    let(:apply_type) { "How do you want candidates to apply for the role?" }

    context "with a school" do
      let(:organisation) { build_stubbed(:school) }

      it "doesnt show the document link" do
        expect(rendered).not_to include("Document name")
      end

      it "has a change application type line" do
        expect(rendered).to include(application_type)
      end

      it "has an apply type line" do
        expect(rendered).to include(apply_type)
      end
    end

    context "with a college" do
      let(:organisation) { build_stubbed(:college) }

      it "doesn't include a change application type line" do
        expect(rendered).not_to include(application_type)
      end

      it "doesn't have an apply type line" do
        expect(rendered).not_to include(apply_type)
      end
    end
  end

  context "with email applications" do
    let(:vacancy) { create(:vacancy, :with_application_form) }

    it "doesnt show the document link" do
      expect(rendered).not_to include("Document name")
      expect(rendered).to include("Application form")
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
    let(:vacancy) { build_stubbed(:vacancy, publish_on: publish_date) }

    it "shows the immediate publish button" do
      expect(rendered).to include(I18n.t("publishers.vacancies.show.heading_component.action.publish"))
    end
  end

  context "when the vacancy is scheduled for future" do
    let(:publish_date) { Date.current + 2.days }
    let(:vacancy) { build_stubbed(:vacancy, publish_on: publish_date) }

    it "shows the scheduled publish button" do
      expect(rendered).to include(I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft"))
    end
  end
end
