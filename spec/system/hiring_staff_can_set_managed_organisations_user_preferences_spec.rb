require "rails_helper"

RSpec.describe "Hiring staff can set managed organisations user preferences" do
  let(:school_1) { create(:school, name: "Happy Rainbows School") }
  let(:school_2) { create(:school, name: "Dreary Grey School") }
  let(:school_3) { create(:school, :closed, name: "Closed School") }
  let(:publisher_preference) { PublisherPreference.last }

  before do
    allow(LocalAuthorityAccessFeature).to receive(:enabled?).and_return(true)
    allow(ALLOWED_LOCAL_AUTHORITIES).to receive(:include?).with(school_group.local_authority_code).and_return(true)

    SchoolGroupMembership.find_or_create_by(school_id: school_1.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_2.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_3.id, school_group_id: school_group.id)

    stub_accepted_terms_and_conditions
    OmniAuth.config.test_mode = true

    stub_authentication_step(school_urn: nil, trust_uid: school_group.uid, la_code: school_group.local_authority_code)
    stub_authorisation_step
    stub_sign_in_with_multiple_organisations

    visit root_path
    sign_in_user
  end

  after do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    OmniAuth.config.test_mode = false
  end

  context "when current_organisation is a trust" do
    let(:school_group) { create(:trust) }

    scenario "it shows the trust head office option" do
      visit organisation_managed_organisations_path
      expect(page.current_path).to eql(organisation_managed_organisations_path)
      expect(page).to have_content(I18n.t("publishers.organisations.managed_organisations.show.options.school_group"))
    end

    scenario "it does not show closed school option" do
      visit organisation_managed_organisations_path
      expect(page.current_path).to eql(organisation_managed_organisations_path)
      expect(page).not_to have_content(school_3.name)
    end

    scenario "it allows school group users to select which organisation's jobs they want to manage" do
      visit organisation_managed_organisations_path

      expect(page).to have_content(
        I18n.t("publishers.organisations.managed_organisations.show.panel.title", organisation: school_group.name),
      )

      check I18n.t("publishers.organisations.managed_organisations.show.options.school_group"),
            name: "managed_organisations_form[managed_school_ids][]", visible: false
      check school_1.name, name: "managed_organisations_form[managed_school_ids][]", visible: false

      click_on I18n.t("buttons.continue")

      expect(page.current_path).to eql(organisation_path)
      expect(publisher_preference.managed_school_ids).to eql([school_group.id, school_1.id])
    end

    scenario "it allows school group users to select to manage all jobs" do
      visit organisation_managed_organisations_path

      expect(page).to have_content(
        I18n.t("publishers.organisations.managed_organisations.show.panel.title", organisation: school_group.name),
      )

      check I18n.t("publishers.organisations.managed_organisations.show.options.all"),
            name: "managed_organisations_form[managed_organisations][]", visible: false
      check school_1.name, name: "managed_organisations_form[managed_school_ids][]", visible: false

      click_on I18n.t("buttons.continue")

      expect(page.current_path).to eql(organisation_path)
      expect(publisher_preference.managed_organisations).to eql("all")
      expect(publisher_preference.managed_school_ids).to eql([])
    end
  end

  context "when current_organisation is a local_authority" do
    let(:school_group) { create(:local_authority) }

    scenario "it does not show the trust head office option" do
      visit organisation_managed_organisations_path
      expect(page.current_path).to eql(organisation_managed_organisations_path)
      expect(page).not_to have_content(
        I18n.t("publishers.organisations.managed_organisations.show.options.school_group"),
      )
    end
  end
end
