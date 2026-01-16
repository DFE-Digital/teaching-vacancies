require "rails_helper"

RSpec.describe "Jobseekers can apply for a vacancy" do
  before { visit job_path(vacancy) }

  context "with a website vacancy" do
    let(:expected_link) { I18n.t("jobs.view_advert.school", href: "http://www.google.com") }

    context "with a published vacancy" do
      let(:vacancy) do
        create(:vacancy, :no_tv_applications,
               application_link: "www.google.com", organisations: [build(:school)])
      end

      it "has an application link" do
        expect(page).to have_link(expected_link)
      end
    end

    context "with an expired vacancy" do
      let(:vacancy) do
        create(:vacancy, :expired, :no_tv_applications,
               application_link: "www.google.com", organisations: [build(:school)])
      end

      it "does not have an application link" do
        expect(page).not_to have_link(expected_link)
      end
    end
  end

  context "with a download form vacancy" do
    let(:vacancy) do
      create(:vacancy, :with_application_form,
             organisations: [build(:school)])
    end
    let(:jobseeker) { create(:jobseeker) }
    let(:expected_content) { "Download an application form" }

    it "apply link can only be found after login" do
      expect(page).not_to have_content(expected_content)
      all(".govuk-button").last.click
      sign_in_jobseeker_govuk_one_login(jobseeker)
      expect(page).to have_content(expected_content)
    end
  end
end
