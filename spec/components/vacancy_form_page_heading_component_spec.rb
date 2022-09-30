require "rails_helper"

RSpec.describe VacancyFormPageHeadingComponent, type: :component do
  let(:organisation) { create(:school, name: "Teaching Vacancies Academy") }
  let(:vacancy) { create(:vacancy, status, organisations: [organisation], job_title: "Test job title", completed_steps: %w[job_location job_role review]) }
  let(:status) { :published }
  let(:current_publisher_is_part_of_school_group?) { true }
  let(:steps) { %i[job_location job_role review] }

  let(:vacancy_step_process) do
    instance_double(Publishers::Vacancies::VacancyStepProcess, current_step: "job_location",
                                                               vacancy: vacancy,
                                                               organisation: organisation)
  end

  subject { described_class.new(vacancy, vacancy_step_process) }

  before do
    allow(subject).to receive(:current_organisation).and_return(organisation)
    allow(vacancy_step_process).to receive(:previous_step).and_return(previous_step)
    allow(vacancy_step_process).to receive(:steps).and_return(steps)
    allow(vacancy_step_process).to receive(:current_step_group_number).and_return(1)
    allow(vacancy_step_process).to receive(:total_step_groups).and_return(3)

    render_inline(subject)
  end

  describe "caption" do
    let(:previous_step) { :review }

    context "when vacancy is not published" do
      let(:status) { :draft }

      it "shows the create caption with current step" do
        expect(page).to have_content(I18n.t("jobs.create_job_caption", step: 1, total: 2))
      end
    end

    context "when vacancy is published" do
      it "shows the edit caption with current step" do
        expect(page).to have_content(I18n.t("jobs.edit_job_caption", step: 1, total: 2))
      end
    end
  end

  describe "#heading" do
    let(:previous_step) { :review }

    it "returns edit job title" do
      expect(page).to have_content(I18n.t("publishers.vacancies.steps.#{vacancy_step_process.current_step}"))
    end
  end
end
