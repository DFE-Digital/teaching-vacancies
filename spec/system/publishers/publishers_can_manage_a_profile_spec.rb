require "rails_helper"

RSpec.describe "Publishers can manage an organisation or school profile" do
  let(:publisher) { create(:publisher, organisations: [organisation]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit publisher_root_path
  end

  describe "changing the organisation's website" do
    context "when the publisher is signed in as a school" do
      let(:organisation) { create(:school) }
      let(:school_website_url) { "https://www.this-is-a-test-url.example.com" }

      before { click_on I18n.t("nav.school_profile") }

      it "allows the publisher to edit the school's website" do
        within("div.govuk-summary-list__row#website") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_url_override_form[url_override]").value).to be_blank

        fill_in "publishers_organisation_url_override_form[url_override]", with: school_website_url
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(school_website_url)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "School"))
        expect(page).to have_current_path(publishers_organisation_path(organisation), ignore_query: true)
      end
    end

    context "when the publisher is signed in as a trust" do
      let(:organisation) { create(:trust, schools: [school1, school2], url_override: trust_website_url) }
      let(:school1) { create(:school, url_override: school_website_url) }
      let(:school2) { create(:school) }
      let(:trust_website_url) { "https://www.this-is-a-test-url-for-a-trust.example.com" }
      let(:new_trust_website_url) { "https://www.this-is-a-new-test-url-for-a-trust.example.com" }
      let(:school_website_url) { "https://www.this-is-a-test-url-for-a-school.example.com" }
      let(:new_school_website_url) { "https://www.this-is-a-new-test-url-for-a-school.example.com" }

      before { click_on I18n.t("nav.organisation_profile") }

      it "allows the publisher to edit the trust's website" do
        within("div.govuk-summary-list__row#website") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_url_override_form[url_override]").value).to eq(trust_website_url)

        fill_in "publishers_organisation_url_override_form[url_override]", with: new_trust_website_url
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(new_trust_website_url)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "Organisation"))
        expect(page).to have_current_path(publishers_organisation_path(organisation), ignore_query: true)
      end

      it "allows the publisher to navigate and edit a school's website" do
        click_on school1.name

        within("div.govuk-summary-list__row#website") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_url_override_form[url_override]").value).to eq(school_website_url)

        fill_in "publishers_organisation_url_override_form[url_override]", with: new_school_website_url
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(new_school_website_url)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "School"))
        expect(page).to have_current_path(publishers_organisation_path(school1), ignore_query: true)
      end
    end

    context "when the publisher is signed in as a local authority" do
      let(:organisation) { create(:local_authority) }
      let(:local_authority_website) { "https://www.this-is-a-new-test-url-for-a-local-authority.example.com" }

      before { click_on I18n.t("nav.organisation_profile") }

      it "allows the publisher to edit the local authority's website" do
        within("div.govuk-summary-list__row#website") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_url_override_form[url_override]").value).to be_blank

        fill_in "publishers_organisation_url_override_form[url_override]", with: local_authority_website
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(local_authority_website)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "Organisation"))
        expect(page).to have_current_path(publishers_organisation_path(organisation), ignore_query: true)
      end
    end
  end

  describe "changing the organisation's description" do
    context "when the publisher is signed in as a school" do
      let(:organisation) { create(:school) }
      let(:school_description) { "A lovely place" }

      before { click_on I18n.t("nav.school_profile") }

      it "allows the publisher to edit the school's description" do
        within("div.govuk-summary-list__row#description") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_description_form[description]").value).to eq(organisation.description)

        fill_in "publishers_organisation_description_form[description]", with: school_description
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(school_description)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "School"))
        expect(page).to have_current_path(publishers_organisation_path(organisation), ignore_query: true)
      end
    end

    context "when the publisher is signed in as a trust" do
      let(:organisation) { create(:trust, schools: [school1, school2]) }
      let(:school1) { create(:school) }
      let(:school2) { create(:school) }
      let(:new_trust_description) { "A lovely trust" }
      let(:new_school_description) { "A lovely school" }

      before { click_on I18n.t("nav.organisation_profile") }

      it "allows the publisher to edit the trust's description" do
        within("div.govuk-summary-list__row#description") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_description_form[description]").value).to eq(organisation.description)

        fill_in "publishers_organisation_description_form[description]", with: new_trust_description
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(new_trust_description)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "Organisation"))
        expect(page).to have_current_path(publishers_organisation_path(organisation), ignore_query: true)
      end

      it "allows the publisher to navigate and edit a school's description" do
        click_on school1.name

        within("div.govuk-summary-list__row#description") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_description_form[description]").value).to eq(school1.description)

        fill_in "publishers_organisation_description_form[description]", with: new_school_description
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(new_school_description)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "School"))
        expect(page).to have_current_path(publishers_organisation_path(school1), ignore_query: true)
      end
    end

    context "when the publisher is signed in as a local authority" do
      let(:organisation) { create(:local_authority) }
      let(:local_authority_description) { "A lovely local authority" }

      before { click_on I18n.t("nav.organisation_profile") }

      it "allows the publisher to edit the local authority's description" do
        within("div.govuk-summary-list__row#description") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_description_form[description]").value).to be_empty

        fill_in "publishers_organisation_description_form[description]", with: local_authority_description
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(local_authority_description)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "Organisation"))
        expect(page).to have_current_path(publishers_organisation_path(organisation), ignore_query: true)
      end
    end
  end

  describe "changing the organisation's email" do
    context "when the publisher is signed in as a school" do
      let(:organisation) { create(:school) }
      let(:school_email) { "me@home.com" }

      before { click_on I18n.t("nav.school_profile") }

      it "allows the publisher to edit the school's email" do
        within("div.govuk-summary-list__row#email") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_email_form[email]").value).to eq(organisation.email)

        fill_in "publishers_organisation_email_form[email]", with: school_email
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(school_email)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "School"))
        expect(page).to have_current_path(publishers_organisation_path(organisation), ignore_query: true)
      end
    end

    context "when the publisher is signed in as a trust" do
      let(:organisation) { create(:trust, schools: [school1, school2]) }
      let(:school1) { create(:school) }
      let(:school2) { create(:school) }
      let(:new_trust_email) { "me@trust.com" }
      let(:new_school_email) { "me@school.com" }

      before { click_on I18n.t("nav.organisation_profile") }

      it "allows the publisher to edit the trust's email" do
        within("div.govuk-summary-list__row#email") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_email_form[email]").value).to eq(organisation.email)

        fill_in "publishers_organisation_email_form[email]", with: new_trust_email
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(new_trust_email)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "Organisation"))
        expect(page).to have_current_path(publishers_organisation_path(organisation), ignore_query: true)
      end

      it "allows the publisher to navigate and edit a school's email" do
        click_on school1.name

        within("div.govuk-summary-list__row#email") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_email_form[email]").value).to eq(school1.email)

        fill_in "publishers_organisation_email_form[email]", with: new_school_email
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(new_school_email)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "School"))
        expect(page).to have_current_path(publishers_organisation_path(school1), ignore_query: true)
      end
    end

    context "when the publisher is signed in as a local authority" do
      let(:organisation) { create(:local_authority) }
      let(:local_authority_email) { "me@authority.com" }

      before { click_on I18n.t("nav.organisation_profile") }

      it "allows the publisher to edit the local authority's email" do
        within("div.govuk-summary-list__row#email") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_email_form[email]").value).to be_blank

        fill_in "publishers_organisation_email_form[email]", with: local_authority_email
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(local_authority_email)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "Organisation"))
        expect(page).to have_current_path(publishers_organisation_path(organisation), ignore_query: true)
      end
    end
  end

  describe "changing the organisation's safeguarding information" do
    context "when the publisher is signed in as a school" do
      let(:organisation) { create(:school) }
      let(:school_safeguarding_information) { "A very safe school" }

      before { click_on I18n.t("nav.school_profile") }

      it "allows the publisher to edit the school's safeguarding information" do
        within("div.govuk-summary-list__row#safeguarding_information") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_safeguarding_information_form[safeguarding_information]").value).to eq(organisation.safeguarding_information)

        fill_in "publishers_organisation_safeguarding_information_form[safeguarding_information]", with: school_safeguarding_information
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(school_safeguarding_information)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "School"))
        expect(page).to have_current_path(publishers_organisation_path(organisation), ignore_query: true)
      end
    end

    context "when the publisher is signed in as a trust" do
      let(:organisation) { create(:trust, schools: [school1, school2]) }
      let(:school1) { create(:school) }
      let(:school2) { create(:school) }
      let(:new_trust_safeguarding_information) { "This trust is very safe" }
      let(:new_school_safeguarding_information) { "This school is very safe" }

      before { click_on I18n.t("nav.organisation_profile") }

      it "allows the publisher to edit the trust's safeguarding information" do
        within("div.govuk-summary-list__row#safeguarding_information") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_safeguarding_information_form[safeguarding_information]").value).to eq(organisation.safeguarding_information)

        fill_in "publishers_organisation_safeguarding_information_form[safeguarding_information]", with: new_trust_safeguarding_information
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(new_trust_safeguarding_information)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "Organisation"))
        expect(page).to have_current_path(publishers_organisation_path(organisation), ignore_query: true)
      end

      it "allows the publisher to navigate and edit a school's description" do
        click_on school1.name

        within("div.govuk-summary-list__row#safeguarding_information") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_safeguarding_information_form[safeguarding_information]").value).to eq(school1.safeguarding_information)

        fill_in "publishers_organisation_safeguarding_information_form[safeguarding_information]", with: new_school_safeguarding_information
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(new_school_safeguarding_information)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "School"))
        expect(page).to have_current_path(publishers_organisation_path(school1), ignore_query: true)
      end
    end

    context "when the publisher is signed in as a local authority" do
      let(:organisation) { create(:local_authority) }
      let(:local_authority_safeguarding_information) { "A very safe local authority" }

      before { click_on I18n.t("nav.organisation_profile") }

      it "allows the publisher to edit the local authority's safeguarding information" do
        within("div.govuk-summary-list__row#safeguarding_information") do
          click_on("Change")
        end

        expect(find_field("publishers_organisation_safeguarding_information_form[safeguarding_information]").value).to eq(organisation.safeguarding_information)

        fill_in "publishers_organisation_safeguarding_information_form[safeguarding_information]", with: local_authority_safeguarding_information
        click_on I18n.t("buttons.save_changes")

        expect(page).to have_content(local_authority_safeguarding_information)
        expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "Organisation"))
        expect(page).to have_current_path(publishers_organisation_path(organisation), ignore_query: true)
      end
    end
  end

  describe "changing the organisation's logo" do
    let(:organisation) { create(:school) }
    let(:image_file_name) { "blank_image.png" }

    before do
      allow_any_instance_of(Publishers::DocumentVirusCheck).to receive(:safe?).and_return(true)
      click_on I18n.t("nav.school_profile")
    end

    it "allows the publisher to edit the organisation's logo" do
      within("div.govuk-summary-list__row#logo") do
        click_on("Change")
      end

      upload_file(
        "new_publishers_organisation_logo_form",
        "publishers-organisation-logo-form-logo-field",
        "spec/fixtures/files/#{image_file_name}",
      )

      expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "School"))
      expect(organisation.reload.logo.attachment.filename.to_s).to eq(image_file_name)
      expect(page).to have_css("img[src*='#{url_for(organisation.logo)}']")
    end
  end

  describe "deleting the organisation's logo" do
    let(:organisation) { create(:school) }
    let(:image_file_name) { "blank_image.png" }

    before do
      allow_any_instance_of(Publishers::DocumentVirusCheck).to receive(:safe?).and_return(true)
      click_on I18n.t("nav.school_profile")
    end

    it "allows the publisher to delete the organisation's logo" do
      within("div.govuk-summary-list__row#logo") do
        click_on("Change")
      end

      click_on I18n.t("publishers.organisations.logo.edit.delete_logo_link")

      expect(page).to have_current_path(confirm_destroy_publishers_organisation_logo_path(organisation), ignore_query: true)

      click_on I18n.t("buttons.delete_logo")

      expect(page).to have_content(I18n.t("publishers.organisations.logo.destroy_success", organisation_type: "School"))
      expect(organisation.reload.logo.attached?).to be false
    end
  end

  describe "changing the organisation's photo" do
    let(:organisation) { create(:school) }
    let(:image_file_name) { "blank_image.png" }

    before do
      allow_any_instance_of(Publishers::DocumentVirusCheck).to receive(:safe?).and_return(true)
      click_on I18n.t("nav.school_profile")
    end

    it "allows the publisher to edit the organisation's photo" do
      within("div.govuk-summary-list__row#photo") do
        click_on("Change")
      end

      upload_file(
        "new_publishers_organisation_photo_form",
        "publishers-organisation-photo-form-photo-field",
        "spec/fixtures/files/#{image_file_name}",
      )

      expect(page).to have_content(I18n.t("publishers.organisations.update_success", organisation_type: "School"))
      expect(organisation.reload.photo.attachment.filename.to_s).to eq(image_file_name)
      expect(page).to have_css("img[src*='#{url_for(organisation.photo)}']")
    end
  end

  describe "deleting the organisation's photo" do
    let(:organisation) { create(:school) }
    let(:image_file_name) { "blank_image.png" }

    before do
      allow_any_instance_of(Publishers::DocumentVirusCheck).to receive(:safe?).and_return(true)
      click_on I18n.t("nav.school_profile")
    end

    it "allows the publisher to delete the organisation's photo" do
      within("div.govuk-summary-list__row#photo") do
        click_on("Change")
      end

      click_on I18n.t("publishers.organisations.photo.edit.delete_photo_link")

      expect(page).to have_current_path(confirm_destroy_publishers_organisation_photo_path(organisation), ignore_query: true)

      click_on I18n.t("buttons.delete_photo")

      expect(page).to have_content(I18n.t("publishers.organisations.photo.destroy_success", organisation_type: "School"))
      expect(organisation.reload.photo.attached?).to be false
    end
  end
end
