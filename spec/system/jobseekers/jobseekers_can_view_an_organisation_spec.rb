# can be a view spec
require "rails_helper"

RSpec.describe "Viewing an organisation" do
  let(:school_group) { create(:trust) }
  let(:organisation) { create(:school, school_groups: [school_group]) }
  let!(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let!(:vacancy_without_apply) { create(:vacancy, :no_tv_applications, organisations: [organisation]) }

  before do
    allow(organisation).to receive(:geopoint?).and_return(true)

    visit organisation_path(organisation)
  end

  it "flags the jobs that allow applications through Teaching Vacancies" do
    expect(page.find("h3 span", text: vacancy.job_title))
      .to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
    expect(page.find("h3 span", text: vacancy_without_apply.job_title))
      .not_to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
  end

  context "when the organisation is a school group" do
    let(:organisation) { create(:trust, schools: [school_one, school_two]) }
    let!(:vacancy) { create(:vacancy, organisations: [organisation]) }
    let(:school_one) { create(:school) }
    let(:school_two) { create(:school) }

    it "flags the jobs that allow applications through Teaching Vacancies" do
      expect(page.find("h3 span", text: vacancy.job_title))
        .to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
      expect(page.find("h3 span", text: vacancy_without_apply.job_title))
        .not_to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
    end
  end
end
