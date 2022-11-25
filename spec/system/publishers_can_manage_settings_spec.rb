require "rails_helper"

RSpec.describe "Publishers can manage organisation/school profile" do
  let(:publisher) { create(:publisher, organisations: [organisation]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit publisher_root_path
  end

  context "when publisher logs in as a school" do
    before do
      click_link I18n.t("nav.school_profile")
    end

    let(:organisation) { create(:school) }

    it "allows to edit the school details" do
      click_link("Change", match: :first)

      expect(find_field("publishers_organisation_form[url_override]").value).to be_nil

      fill_in "publishers_organisation_form[description]", with: "Our school prides itself on excellence."
      fill_in "publishers_organisation_form[url_override]", with: "https://www.this-is-a-test-url.example.com"
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_content(I18n.t("publishers.organisations.update.success", organisation_type: "School"))
      expect(page.current_path).to eq(publishers_organisation_path(organisation))
    end
  end

  context "when publisher logs in as a trust" do
    before do
      click_link I18n.t("nav.organisation_profile")
    end

    let(:organisation) { create(:trust, schools: [school1, school2]) }
    let(:school1) { create(:school, url_override: "http://example.com") }
    let(:school2) { create(:school) }

    it "allows to edit the trust details" do
      click_link("Change", match: :first)

      expect(find_field("publishers_organisation_form[url_override]").value).to eq(organisation.url_override)

      fill_in "publishers_organisation_form[description]", with: "Our school prides itself on excellence."
      fill_in "publishers_organisation_form[url_override]", with: "https://www.this-is-a-test-url.example.com"
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_content(I18n.t("publishers.organisations.update.success", organisation_type: "Organisation"))
      expect(page.current_path).to eq(publishers_organisation_path(organisation))
    end

    it "allows to navigate and manage school's profile settings page" do
      click_on school1.name

      click_link "Change", match: :first

      expect(find_field("publishers_organisation_form[url_override]").value).to eq(school1.url_override)

      fill_in "publishers_organisation_form[description]", with: "Our school prides itself on excellence."
      fill_in "publishers_organisation_form[url_override]", with: "https://www.this-is-a-test-url.example.com"
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_content(I18n.t("publishers.organisations.update.success", organisation_type: "School"))
      expect(page.current_path).to eq(publishers_organisation_path(school1))
    end
  end

  context "when publisher logs in as a local_authority" do
    before do
      click_link I18n.t("nav.organisation_profile")
    end

    let(:organisation) { create(:local_authority, schools: [school1, school2]) }
    let(:school1) { create(:school, url_override: "http://example.com") }
    let(:school2) { create(:school) }

    it "allows to edit the local_authority details" do
      click_link("Change", match: :first)

      fill_in "publishers_organisation_form[description]", with: "Our school prides itself on excellence."
      fill_in "publishers_organisation_form[url_override]", with: "https://www.this-is-a-test-url.example.com"
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_content(I18n.t("publishers.organisations.update.success", organisation_type: "Organisation"))
      expect(page.current_path).to eq(publishers_organisation_path(organisation))
    end
  end
end
