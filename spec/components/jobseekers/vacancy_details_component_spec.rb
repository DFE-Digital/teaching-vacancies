require "rails_helper"

RSpec.describe Jobseekers::VacancyDetailsComponent, type: :component do
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    vacancy.organisation_vacancies.create(organisation: organisation)
    render_inline(described_class.new(vacancy: vacancy_presenter))
  end

  it "renders the job title label" do
    expect(rendered_component).to include(I18n.t("jobs.job_roles"))
  end

  it "renders the job role" do
    expect(rendered_component).to include(vacancy_presenter.show_job_roles)
  end

  it "renders the subjects label" do
    expect(rendered_component).to include(I18n.t("jobs.subject", count: vacancy.subjects&.count))
  end

  it "renders the working pattern" do
    expect(rendered_component).to include(vacancy_presenter.working_patterns)
  end

  it "renders the salary" do
    expect(rendered_component).to include(vacancy.salary)
  end

  it "renders the job summary" do
    expect(rendered_component).to include(vacancy.job_summary)
  end

  context "when benefits are present" do
    it "renders the benefits label" do
      expect(rendered_component).to include(I18n.t("jobs.benefits"))
    end

    it "renders the benefits" do
      expect(rendered_component).to include(vacancy_presenter.benefits)
    end
  end

  context "when benefits are not present" do
    let(:vacancy) { create(:vacancy, benefits: "") }

    it "does not render the benefits label" do
      expect(rendered_component).not_to include(I18n.t("jobs.benefits"))
    end
  end

  context "when vacancy does not enable job applications" do
    let(:vacancy) { create(:vacancy, :no_tv_applications) }

    it "renders the how_to_apply label" do
      expect(rendered_component).to include(I18n.t("jobs.applying_for_the_job"))
    end

    it "renders the how_to_apply" do
      expect(rendered_component).to include(vacancy_presenter.how_to_apply)
    end

    it "renders the application link" do
      expect(rendered_component).to include(Rails.application.routes.url_helpers.new_job_interest_path(vacancy.id))
    end
  end

  context "when vacancy enables job applications" do
    it "renders the how_to_apply label and description" do
      expect(rendered_component).to include(I18n.t("jobseekers.job_applications.applying_for_the_role_heading"))
      expect(rendered_component).to include(I18n.t("jobseekers.job_applications.applying_for_the_role_paragraph"))
    end

    it "renders the application link" do
      expect(rendered_component)
        .to include(Rails.application.routes.url_helpers.new_jobseekers_job_job_application_path(vacancy.id))
    end
  end
end
