require "rails_helper"

RSpec.describe "Publishers can manage settings" do
  let(:publisher) { create(:publisher, organisations: [organisation]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_path
    click_link(I18n.t("nav.manage_settings"))
  end

  context "when publisher logs in as a school" do
    let(:organisation) { create(:school) }

    it "allows to edit the school details" do
      click_link("Change", match: :first)

      expect(find_field("publishers_organisation_form[url_override]").value).to be_nil

      fill_in "publishers_organisation_form[description]", with: "Our school prides itself on excellence."
      fill_in "publishers_organisation_form[url_override]", with: "https://www.this-is-a-test-url.example.com"
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_content("Details updated for #{organisation.name}")
      expect(page.current_path).to eq(publishers_school_path(organisation))
    end
  end

  context "when publisher logs in as a trust" do
    let(:organisation) { create(:trust, schools: [school1, school2]) }
    let(:school1) { create(:school, url_override: "http://example.com") }
    let(:school2) { create(:school) }

    it "allows to edit the trust details" do
      click_link("Change", match: :first)

      expect(find_field("publishers_organisation_form[url_override]").value).to eq(organisation.url_override)

      fill_in "publishers_organisation_form[description]", with: "Our school prides itself on excellence."
      fill_in "publishers_organisation_form[url_override]", with: "https://www.this-is-a-test-url.example.com"
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_content("Details updated for #{organisation.name}")
      expect(page.current_path).to eq(publishers_schools_path)
    end

    it "allows to edit details of a school in the trust" do
      within("//details[@data-id=\"#{school1.id}\"]") { click_link("Change", match: :first, visible: false) }

      expect(find_field("publishers_organisation_form[url_override]").value).to eq(school1.url_override)

      fill_in "publishers_organisation_form[description]", with: "Our school prides itself on excellence."
      fill_in "publishers_organisation_form[url_override]", with: "https://www.this-is-a-test-url.example.com"
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_content("Details updated for #{school1.name}")
      expect(page.current_path).to eq(publishers_schools_path)
    end
  end

  context "when publisher logs in as a local_authority" do
    let(:organisation) { create(:local_authority, schools: [school1, school2]) }
    let(:school1) { create(:school, url_override: "http://example.com") }
    let(:school2) { create(:school) }

    it "allows to edit the local_authority details" do
      click_link("Change", match: :first)

      fill_in "publishers_organisation_form[description]", with: "Our school prides itself on excellence."
      fill_in "publishers_organisation_form[url_override]", with: "https://www.this-is-a-test-url.example.com"
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_content("Details updated for #{organisation.name}")
      expect(page.current_path).to eq(publishers_schools_path)
    end

    it "allows to edit details of a school in the local_authority" do
      within("//details[@data-id=\"#{school1.id}\"]") { click_link("Change", match: :first, visible: false) }

      expect(find_field("publishers_organisation_form[url_override]").value).to eq(school1.url_override)

      fill_in "publishers_organisation_form[description]", with: "Our school prides itself on excellence."
      fill_in "publishers_organisation_form[url_override]", with: "https://www.this-is-a-test-url.example.com"
      click_on I18n.t("buttons.save_changes")

      expect(page).to have_content("Details updated for #{school1.name}")
      expect(page.current_path).to eq(publishers_schools_path)
    end
  end
end
