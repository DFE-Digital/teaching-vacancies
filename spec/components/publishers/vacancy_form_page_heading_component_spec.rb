require "rails_helper"

RSpec.describe Publishers::VacancyFormPageHeadingComponent, type: :component do
  let(:organisation) { create(:school, name: "Teaching Vacancies Academy") }
  let(:vacancy) { create(:vacancy, status, organisations: [organisation], job_title: "Test job title", completed_steps: %w[step_one step_two]) }
  let(:status) { :published }
  let(:current_publisher_is_part_of_school_group?) { true }
  let(:steps) { %i[step_one step_two] }

  let(:vacancy_step_process) do
    instance_double(Publishers::Vacancies::VacancyStepProcess, current_step: "step_one",
                                                               vacancy:,
                                                               organisation:,
                                                               session: {})
  end

  subject { described_class.new(vacancy, vacancy_step_process) }

  before do
    allow(subject).to receive(:current_organisation).and_return(organisation)
    allow(vacancy_step_process).to receive(:previous_step).and_return(previous_step)
    allow(vacancy_step_process).to receive(:previous_step_or_review).and_return(previous_step)
    allow(vacancy_step_process).to receive(:steps).and_return(steps)
    allow(vacancy_step_process).to receive(:current_step_group_number).and_return(1)
    allow(vacancy_step_process).to receive(:total_step_groups).and_return(2)

    render_inline(subject)
  end

  describe "caption" do
    let(:previous_step) { :review }

    context "when vacancy is not published" do
      let(:status) { :draft }

      it "shows the current step" do
        expect(rendered_component).to include(I18n.t("jobs.current_step", step: 1, total: 2))
      end
    end

    context "when vacancy is published" do
      it "does not show the current step" do
        expect(rendered_component).not_to include("Step")
      end
    end
  end

  describe "#heading" do
    let(:previous_step) { :review }

    context "when the vacancy is published" do
      it "returns edit job title" do
        expect(rendered_component).to include(I18n.t("jobs.edit_job_title", job_title: "Test job title"))
      end
    end

    context "when the vacancy is not published" do
      let(:status) { :draft }

      it "returns create a job title" do
        expect(rendered_component).to include(I18n.t("jobs.create_a_job_title", organisation: "Teaching Vacancies Academy"))
      end
    end
  end

  describe "back_path" do
    context "when the user came from the review or manage job listing page" do
      let(:previous_step) { :review }

      context "when the vacancy has been completed" do
        it "renders a back link to the review page" do
          assert_includes rendered_component, Rails.application.routes.url_helpers.organisation_job_review_path(vacancy.id)
        end
      end

      context "when the vacancy has not been completed" do
        before { vacancy.completed_steps = %i[step_one] }

        it "renders a back link to the manage listing page" do
          assert_includes rendered_component, Rails.application.routes.url_helpers.organisation_job_path(vacancy.id)
        end
      end
    end

    context "when the user came from another step" do
      let(:previous_step) { :step_one }

      it "renders a back link to the previous step" do
        assert_includes rendered_component, Rails.application.routes.url_helpers.organisation_job_build_path(vacancy.id, previous_step)
      end
    end
  end
end
