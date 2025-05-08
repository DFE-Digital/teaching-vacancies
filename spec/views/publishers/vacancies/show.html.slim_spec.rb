require "rails_helper"

RSpec.describe "publishers/vacancies/show" do
  before do
    assign :vacancy, VacancyPresenter.new(vacancy)
    assign :next_invalid_step, next_invalid_step
    assign :step_process, Publishers::Vacancies::VacancyStepProcess.new(
      :review,
      vacancy: vacancy,
      organisation: school,
    )
    assign :organisation, school
    render
  end

  let(:school) { build(:school) }

  let(:job_details) { rendered.html.css("#job_details") }
  let(:about_the_role) { rendered.html.css("#about_the_role") }
  let(:important_dates) { rendered.html.css("#important_dates") }
  let(:application_process) { rendered.html.css("#application_process") }
  let(:publish_on) { nil }

  context "with a minimal vacancy" do
    let(:vacancy) { create(:vacancy, :without_contract_details, publish_on: publish_on) }
    let(:next_invalid_step) { :job_role }

    it "show first section as in-progress, and the rest as not startable" do
      expect(job_details).to have_content "In progress"
      expect(about_the_role).to have_content "Cannot start yet"
      expect(important_dates).to have_content "Cannot start yet"
      expect(application_process).to have_content "Cannot start yet"
    end
  end

  context "with just a complete first section" do
    let(:vacancy) { create(:vacancy, :with_contract_details) }
    let(:next_invalid_step) { :working_patterns }

    it "show first section as complete" do
      expect(job_details).to have_content "Completed"
      expect(about_the_role).to have_content "Not started"
      expect(important_dates).to have_content "Cannot start yet"
      expect(application_process).to have_content "Cannot start yet"
    end
  end

  context "when the vacancy is published today" do
    let(:publish_on) { Date.current }

    it "shows the immediate publish button" do
      expect(rendered).to include(I18n.t("publishers.vacancies.show.heading_component.action.publish"))
    end
  end
end
