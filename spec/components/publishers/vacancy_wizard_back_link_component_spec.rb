require "rails_helper"

RSpec.describe Publishers::VacancyWizardBackLinkComponent, type: :component do
  subject { described_class.new(vacancy, previous_step_path: previous_step_path, current_step_is_first_step: current_step_is_first_step) }

  let(:previous_step_path) { "/some/where" }

  before do
    render_inline(subject)
  end

  context "when the vacancy is first being created" do
    let(:vacancy) { build_stubbed(:vacancy, state: "create") }

    context "when the current step is the first step" do
      let(:current_step_is_first_step) { true }

      it "does not render" do
        expect(rendered_component).to be_blank
      end
    end

    context "when the current step is not the first step" do
      let(:current_step_is_first_step) { false }

      it "renders a 'back' link to the previous path given" do
        expect(rendered_component).to include(I18n.t("buttons.back"))
        expect(rendered_component).to include('href="/some/where"')
      end
    end
  end

  context "when the vacancy has already been fully created" do
    let(:vacancy) { create(:vacancy, id: 3, state: "review", status: status) }
    let(:current_step_is_first_step) { false }

    context "when the vacancy is already published" do
      let(:status) { :published }

      it "renders a 'cancel and return' link to the edit action" do
        expect(rendered_component).to include(I18n.t("buttons.cancel_and_return"))
        expect(rendered_component).to include(Rails.application.routes.url_helpers.edit_organisation_job_path(vacancy.id))
      end
    end

    context "when the vacancy is not yet published" do
      let(:status) { :draft }

      it "renders a 'cancel and return' link to the review action" do
        expect(rendered_component).to include(I18n.t("buttons.cancel_and_return"))
        expect(rendered_component).to include(Rails.application.routes.url_helpers.organisation_job_review_path(vacancy.id))
      end
    end
  end
end
