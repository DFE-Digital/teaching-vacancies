require "rails_helper"

RSpec.describe Jobseekers::VacancyDetailsComponent, type: :component do
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  before do
    render_inline(described_class.new(vacancy: vacancy_presenter))
  end

  context "when a job role is present" do
    it "renders the job title label" do
      expect(rendered_component).to include(I18n.t("jobs.job_role"))
    end

    it "renders the job role" do
      expect(rendered_component).to include(vacancy_presenter.all_job_roles)
    end
  end

  context "when job roles are not present" do
    let(:vacancy) { create(:vacancy, job_roles: %w[]) }

    it "does not render the job title label" do
      expect(rendered_component).not_to include(I18n.t("jobs.job_role"))
    end
  end

  context "when a subject is present" do
    it "renders the subjects label" do
      expect(rendered_component).to include(I18n.t("jobs.subject", count: vacancy.subjects&.count))
    end
  end

  context "when subjects are not present" do
    let(:vacancy) { create(:vacancy, subjects: %w[]) }

    it "does not render the subjects label" do
      expect(rendered_component).not_to include(I18n.t("jobs.subject", count: vacancy.subjects&.count))
    end
  end

  context "when key stages are present" do
    let(:vacancy) { create(:vacancy, key_stages: %w[ks1]) }

    it "renders the key stages label" do
      expect(rendered_component).to include(I18n.t("jobs.key_stage", count: vacancy.key_stages&.count))
    end
  end

  context "when key stages are not present" do
    it "does not render the subjects label" do
      expect(rendered_component).not_to include(I18n.t("jobs.key_stage", count: vacancy.key_stages&.count))
    end
  end

  it "renders the working pattern" do
    expect(rendered_component).to include(vacancy_presenter.working_patterns)
  end

  context "when actual_salary is present" do
    let(:vacancy) { create(:vacancy, working_patterns: ["part_time"], actual_salary: "5000") }

    it "renders the fte salary label" do
      expect(rendered_component).to include(I18n.t("jobs.annual_salary"))
    end

    it "renders the salary" do
      expect(rendered_component).to include(vacancy.salary)
    end

    it "renders the actual salary" do
      expect(rendered_component).to include(vacancy.actual_salary)
    end
  end

  context "when actual_salary is not present" do
    let(:vacancy) { create(:vacancy, working_patterns: ["full_time"], actual_salary: "") }

    it "renders the salary" do
      expect(rendered_component).to include(vacancy.salary)
    end
  end

  it "renders the job summary" do
    expect(rendered_component).to include(vacancy.job_advert)
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
      expect(rendered_component).to include(I18n.t("publishers.vacancies.steps.applying_for_the_job"))
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
      expect(rendered_component).to include(I18n.t("jobseekers.job_applications.applying_for_the_job_heading"))
      expect(rendered_component).to include(I18n.t("jobseekers.job_applications.applying_for_the_job_paragraph"))
    end

    it "renders the application link" do
      expect(rendered_component)
        .to include(Rails.application.routes.url_helpers.new_jobseekers_job_job_application_path(vacancy.id))
    end
  end

  context "when the vacancy has expired" do
    let(:vacancy) { create(:vacancy, :expired) }

    it "does not render the application headings" do
      expect(rendered_component).not_to include(I18n.t("publishers.vacancies.steps.applying_for_the_job"))
      expect(rendered_component).not_to include(I18n.t("jobseekers.job_applications.applying_for_the_role_heading"))
    end

    it "renders the expiry warning text" do
      expect(rendered_component).to include(I18n.t("jobs.expired_listing.notification"))
    end
  end
end
