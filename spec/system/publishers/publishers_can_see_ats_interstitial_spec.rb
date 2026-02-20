require "rails_helper"

RSpec.describe "ATS and religious form interstitial" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, acknowledged_ats_and_religious_form_interstitial: false, accepted_terms_at: Time.current) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  after { logout }

  context "when the publisher has not yet acknowledged the interstitial" do
    it "redirects to the interstitial page and allows acknowledgement" do
      visit organisation_jobs_with_type_path
      expect(page).to have_current_path(publishers_ats_interstitial_path)

      visit publishers_ats_interstitial_path
      expect(page).to have_content(I18n.t("ats_interstitials.shared.page_title"))

      click_on "acknowledge-interstitial-button"

      expect(page).to have_current_path(organisation_jobs_with_type_path)
      expect(publisher.reload.acknowledged_ats_and_religious_form_interstitial).to be true
    end
  end

  context "when the publisher has already acknowledged the interstitial" do
    let(:publisher) { create(:publisher, acknowledged_ats_and_religious_form_interstitial: true) }

    it "does not show the interstitial and proceeds to the dashboard" do
      visit organisation_jobs_with_type_path

      expect(page).to have_current_path(organisation_jobs_with_type_path)
      expect(page).to have_no_content(I18n.t("ats_interstitials.shared.page_title"))
    end
  end

  context "when the publisher is part of a Multi-Academy Trust (MAT)" do
    let(:organisation) { create(:trust, schools: [create(:school)]) }

    let(:publisher) { create(:publisher, acknowledged_ats_and_religious_form_interstitial: false, accepted_terms_at: Time.current) }

    it "shows the generic interstitial and allows acknowledgement" do
      visit organisation_jobs_with_type_path

      expect(page).to have_current_path(publishers_ats_interstitial_path)
      expect(page).to have_content(I18n.t("ats_interstitials.shared.page_title"))

      expect(page).to have_no_content(I18n.t("ats_interstitials.catholic.faith_paragraph"))

      click_on "acknowledge-interstitial-button"

      expect(page).to have_current_path(organisation_jobs_with_type_path)
      expect(publisher.reload.acknowledged_ats_and_religious_form_interstitial).to be true
    end
  end
end
