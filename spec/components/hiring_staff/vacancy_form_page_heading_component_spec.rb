require "rails_helper"

RSpec.describe HiringStaff::VacancyFormPageHeadingComponent, type: :component do
  let(:organisation) { create(:school, name: "Teaching Vacancies Academy") }
  let(:state) { "create" }
  let(:vacancy) { create(:vacancy, state: state, job_title: "Test job title") }
  let(:session_job_location) { nil }
  let(:session_readable_job_location) { nil }
  let(:session_vacancy_attributes) { { "job_location" => session_job_location, "readable_job_location" => session_readable_job_location } }
  let(:current_step) { 99 }

  subject { described_class.new(vacancy, session_vacancy_attributes) }

  before do
    allow(subject).to receive(:current_step).and_return(current_step)
    allow(subject).to receive(:total_steps).and_return(100)
    allow(subject).to receive(:current_organisation).and_return(organisation)
    vacancy.organisation_vacancies.create(organisation: organisation) if vacancy.present?
    render_inline(subject)
  end

  describe "#show_current_step?" do
    context "when vacancy state is create or review" do
      let(:state) { "create" }

      it "shows the current step" do
        expect(rendered_component).to include(I18n.t("jobs.current_step", step: current_step, total: 100))
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
    context "when there is no vacancy object" do
      let(:vacancy) { nil }

      context "when the user is not signed in as a single school and the current step is 1" do
        let(:organisation) { create(:trust) }
        let(:current_step) { 1 }
        let(:session_job_location) { "at_one_school" }
        let(:session_readable_job_location) { "That Specific School" }

        it "returns the create a job title without an organisation, ignoring the session parameters" do
          expect(
            page.text.split("Step").first.strip,
          ).to eq(I18n.t("jobs.create_a_job_title_no_org"))
        end
      end

      context 'when job_location is "at_one_school"' do
        let(:session_job_location) { "at_one_school" }
        let(:session_readable_job_location) { "That Specific School" }

        it "returns the create a job title with the session vacancy readable job location" do
          expect(rendered_component).to include(I18n.t("jobs.create_a_job_title", organisation: session_readable_job_location))
        end
      end

      context 'when job_location is "at_multiple_schools"' do
        let(:session_job_location) { "at_multiple_schools" }

        it "returns the create a job title with the session vacancy readable job location" do
          expect(rendered_component).to include(I18n.t("jobs.create_a_job_title", organisation: "multiple schools"))
        end
      end
    end

    context "when there is a vacancy object" do
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
end
