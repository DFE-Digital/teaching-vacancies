require "rails_helper"

RSpec.describe "Viewing an organisation" do
  let(:trust) { create(:trust) }
  let(:school_one) { create(:school, school_groups: [trust]) }
  let(:school_two) { create(:school, school_groups: [trust]) }
  let!(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let!(:vacancy_without_apply) { create(:vacancy, :no_tv_applications, organisations: [organisation]) }

  before do
    allow(organisation).to receive(:geopoint?).and_return(true)

    visit organisation_path(organisation)
  end

  context "when on the school page" do
    let(:organisation) { school_one }

    context "when there are other jobs within the trust" do
      before do
        create(:vacancy, organisations: [school_two])
        visit organisation_path(organisation)
      end

      it "shows a link to other roles" do
        expect(page).to have_content("View 3 jobs across #{trust.name}")
      end
    end

    it "flags the jobs that allow applications through Teaching Vacancies" do
      expect(page.find("h3 span", text: vacancy.job_title))
        .to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
      expect(page.find("h3 span", text: vacancy_without_apply.job_title))
        .not_to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
    end
  end

  context "when the organisation is a school group" do
    let(:organisation) { trust }

    it "flags the jobs that allow applications through Teaching Vacancies" do
      expect(page.find("h3 span", text: vacancy.job_title))
        .to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
      expect(page.find("h3 span", text: vacancy_without_apply.job_title))
        .not_to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
    end
  end
end
