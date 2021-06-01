require "rails_helper"

RSpec.describe Publishers::VacancyFormPageHeadingComponent, type: :component do
  let(:organisation) { create(:school, name: "Teaching Vacancies Academy") }
  let(:vacancy) { create(:vacancy, status, job_title: "Test job title") }
  let(:status) { :published }
  let(:current_step_number) { 1 }
  let(:current_publisher_is_part_of_school_group?) { true }
  let(:steps_adjust) { current_publisher_is_part_of_school_group? ? 0 : 1 }
  let(:total_steps) { 2 }

  let(:steps) do
    {
      step_one: { number: 1, title: "step 1" },
      step_two: { number: 2, title: "step 2" },
    }.freeze
  end

  subject { described_class.new(vacancy, current_step_number, total_steps) }

  before do
    allow(subject).to receive(:current_organisation).and_return(organisation)
    vacancy.organisation_vacancies.create(organisation: organisation) if vacancy.present?
    render_inline(subject)
  end

  describe "caption" do
    context "when vacancy is not published" do
      let(:status) { :draft }

      it "shows the current step" do
        expect(rendered_component).to include(I18n.t("jobs.current_step", step: current_step_number, total: total_steps))
      end
    end

    context "when vacancy is published" do
      it "does not show the current step" do
        expect(rendered_component).not_to include("Step")
      end
    end
  end

  describe "#heading" do
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
end
