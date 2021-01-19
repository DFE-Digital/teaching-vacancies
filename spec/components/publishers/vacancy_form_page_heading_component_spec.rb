require "rails_helper"

RSpec.describe Publishers::VacancyFormPageHeadingComponent, type: :component do
  let(:organisation) { create(:school, name: "Teaching Vacancies Academy") }
  let(:state) { "create" }
  let(:vacancy) { create(:vacancy, state: state, job_title: "Test job title") }
  let(:session_job_location) { nil }
  let(:session_readable_job_location) { nil }
  let(:session_vacancy_attributes) { { "job_location" => session_job_location, "readable_job_location" => session_readable_job_location } }
  let(:current_step) { 1 }
  let(:current_publisher_is_part_of_school_group?) { true }
  let(:steps_adjust) { current_publisher_is_part_of_school_group? ? 0 : 1 }

  let(:steps) do
    {
      step_one: { number: 1, title: "step 1" },
      step_two: { number: 2, title: "step 2" },
    }.freeze
  end

  let(:service) { ProcessSteps.new({ steps: steps, adjust: steps_adjust, step: :step_one }) }

  subject { described_class.new(vacancy, service.current_step_number, service.total_steps) }

  before do
    allow(subject).to receive(:current_organisation).and_return(organisation)
    vacancy.organisation_vacancies.create(organisation: organisation) if vacancy.present?
    render_inline(subject)
  end

  describe "#show_current_step?" do
    context "when vacancy state is create or review" do
      let(:state) { "create" }

      it "shows the current step" do
        expect(rendered_component).to include(I18n.t("jobs.current_step", step: current_step, total: 2))
      end
    end

    context "when vacancy state is not create or review" do
      let(:state) { "copy" }

      it "does not show the current step" do
        expect(rendered_component).not_to include("Step")
      end
    end
  end

  describe "#heading" do
    let(:state) { "copy" }

    context "when a published vacancy is being edited" do
      let(:vacancy) { create(:vacancy, :published, state: "edit", job_title: "Test job title") }

      it "returns edit job title" do
        expect(rendered_component).to include(I18n.t("jobs.edit_job_title", job_title: "Test job title"))
      end
    end

    context "when the vacancy is not published" do
      before { allow(vacancy).to receive(:published?).and_return(false) }

      context "when the vacancy state is edit" do
        let(:state) { "edit" }

        before { allow(vacancy).to receive(:published?).and_return(false) }

        it "returns edit job title" do
          expect(rendered_component).to include(I18n.t("jobs.edit_job_title", job_title: "Test job title"))
        end
      end

      context "when vacancy state is copy" do
        let(:state) { "copy" }

        it "returns copy job title " do
          expect(rendered_component).to include(I18n.t("jobs.copy_job_title", job_title: "Test job title"))
        end
      end

      context "when vacancy state is create" do
        let(:state) { "create" }

        it "returns create a job title" do
          expect(rendered_component).to include(I18n.t("jobs.create_a_job_title", organisation: "Teaching Vacancies Academy"))
        end
      end

      context "when vacancy state is review" do
        let(:state) { "review" }

        it "returns create a job title" do
          expect(rendered_component).to include(I18n.t("jobs.create_a_job_title", organisation: "Teaching Vacancies Academy"))
        end
      end
    end
  end
end
