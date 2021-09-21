require "rails_helper"

RSpec.describe "Publishers can edit a draft vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }
  let!(:vacancy) do
    VacancyPresenter.new(build(:vacancy,
                               job_title: "Draft vacancy",
                               working_patterns: %w[full_time part_time],
                               job_roles: %w[teacher]))
  end
  let(:draft_vacancy) { Vacancy.find_by(job_title: vacancy.job_title) }

  before { login_publisher(publisher: publisher, organisation: school) }

  context "editing an incomplete draft vacancy" do
    let(:vacancy) { create(:vacancy, :draft, job_roles: %w[teacher]) }
  end



  context "editing a complete draft vacancy" do
    let(:vacancy) { create(:vacancy, :draft, job_roles: %w[teacher]) }

    before { vacancy.organisation_vacancies.create(organisation: school) }

    # TODO: Currently we visit the review page with this test. Revisit this when fixing the buttons
    describe "#cancel_and_return_later" do
      scenario "can cancel and return from job details page" do
        visit organisation_job_review_path(vacancy.id)

        click_header_link(I18n.t("publishers.vacancies.steps.job_details"))
        expect(page).to have_content(I18n.t("buttons.cancel_and_return"))

        click_on I18n.t("buttons.cancel_and_return")
        expect(page.current_path).to eq(organisation_job_review_path(vacancy.id))
      end
    end

    describe "submitting a completed draft" do
      scenario "can submit a completed draft from the manage job listing page" do
        visit organisation_job_path(vacancy.id)

        click_on I18n.t("buttons.submit_job_listing")

        expect(page.current_path).to eq(organisation_job_summary_path(vacancy.id))
      end
    end
  end
end
