require "rails_helper"
require "message_encryptor"

RSpec.shared_examples "a successful sign in" do
  before do
    visit root_path
  end

  scenario "it displays the Hiring staff sign-in section" do
    within ".search-panel-banner .govuk-grid-column-one-third" do
      expect(page).to have_content(I18n.t("home.index.publisher_signin.title"))
      expect(page).to have_content(I18n.t("home.index.publisher_signin.description_html",
                                          signin_link: I18n.t("home.index.publisher_signin.link_text.sign_in"),
                                          signup_link: I18n.t("home.index.publisher_signin.link_text.sign_up")))
      expect(page).to have_link(I18n.t("home.index.publisher_signin.link_text.sign_in"), href: publishers_sign_in_path)
      expect(page).to have_link(I18n.t("home.index.publisher_signin.link_text.sign_up"), href: page_path("dsi-account-request"))
    end
  end

  scenario "it signs in the user successfully" do
    expect { sign_in_publisher }
      .to have_triggered_event(:publisher_sign_in_attempt)
      .with_base_data(user_anonymised_publisher_id: anonymised_form_of(user_oid))
      .and_data(success: "true", sign_in_type: "dsi")

    within("nav") { expect(page).to have_selector(:link_or_button, I18n.t("nav.sign_out")) }
    within("nav") { expect(page).to have_selector(:link_or_button, I18n.t("nav.school_page_link")) }
  end

  scenario "it does not display the Hiring staff sign-in section" do
    sign_in_publisher
    visit root_path

    within ".search-panel-banner .govuk-grid-column-one-third" do
      expect(page).not_to have_content(I18n.t("home.index.publisher_signin.title"))
      expect(page).not_to have_content(I18n.t("home.index.publisher_signin.description_html",
                                              signin_link: I18n.t("home.index.publisher_signin.link_text.sign_in"),
                                              signup_link: I18n.t("home.index.publisher_signin.link_text.sign_up")))
      expect(page).not_to have_link(I18n.t("home.index.publisher_signin.link_text.sign_in"), href: publishers_sign_in_path)
      expect(page).not_to have_link(I18n.t("home.index.publisher_signin.link_text.sign_up"), href: page_path("dsi-account-request"))
    end
  end
end

RSpec.shared_examples "a failed sign in" do |options|
  scenario "it does not sign-in the user, and tells the user what to do" do
    visit root_path

    expect { sign_in_publisher }
      .to have_triggered_event(:publisher_sign_in_attempt)
      .with_data(success: "false", sign_in_type: "dsi", user_anonymised_publisher_id: anonymised_form_of(user_oid))

    expect(page).to have_content(/The email you're signed in with isn't authorised to list jobs for this school/i)
    expect(page).to have_content(options[:email])
    within("nav") { expect(page).not_to have_content(I18n.t("nav.school_page_link")) }
  end
end

RSpec.describe "Publishers can sign in with DfE Sign In" do
  let(:user_oid) { "161d1f6a-44f1-4a1a-940d-d1088c439da7" }
  let(:dsi_email_address) { Faker::Internet.email(domain: "example.com") }

  before do
    allow(AuthenticationFallback).to receive(:enabled?) { false }
    stub_accepted_terms_and_conditions
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    OmniAuth.config.test_mode = false
  end

  context "with valid credentials that match a school" do
    let!(:organisation) { create(:school, urn: "110627") }

    before do
      stub_authentication_step email: dsi_email_address
      stub_authorisation_step
      stub_sign_in_with_multiple_organisations
    end

    it_behaves_like "a successful sign in"

    scenario "it redirects the sign in page to the school page" do
      visit root_path
      sign_in_publisher
      visit new_publisher_session_path

      expect(page).to have_content(organisation.name)
      expect(page).to have_content(dsi_email_address)
      expect(current_path).to eq(organisation_path)
    end
  end

  context "with DSI data including a school group (trust or local authority) that the school belongs to" do
    let(:publisher) { Publisher.find_by(oid: user_oid) }
    let(:school) { create(:school, urn: "246757") }

    before do
      SchoolGroupMembership.create(school_group: school_group, school: school)
      OrganisationPublisher.create(organisation: school, publisher: publisher)
      OrganisationPublisher.create(organisation: school_group, publisher: publisher)

      stub_authentication_step(school_urn: "246757", email: dsi_email_address)
      stub_authorisation_step
      stub_sign_in_with_multiple_organisations

      visit root_path
      sign_in_publisher
    end

    context "with trust" do
      let(:school_group) { create(:trust, uid: "14323") }

      it "associates the user with the trust instead of the school" do
        expect(current_path).to eq(organisation_path)
      end

      it "shows the trust name" do
        expect(page).to have_content(school_group.name)
      end
    end

    context "with local_authority" do
      let(:school_group) { create(:local_authority, local_authority_code: "323") }

      it "associates the user with the local_authority instead of the school" do
        expect(current_path).to eq(new_publisher_preference_path)
      end

      it "shows the local_authority name" do
        expect(page).to have_content(school_group.name)
      end
    end
  end

  context "with valid credentials that match a Trust" do
    let(:organisation) { create(:trust) }
    let(:publisher_preference) { instance_double(PublisherPreference) }

    before do
      allow(PublisherPreference).to receive(:find_by).and_return(publisher_preference)

      stub_authentication_step(school_urn: nil, trust_uid: organisation.uid, email: dsi_email_address)
      stub_authorisation_step
      stub_sign_in_with_multiple_organisations
    end

    it_behaves_like "a successful sign in"

    scenario "it redirects the sign in page to the trust page" do
      visit root_path
      sign_in_publisher
      visit new_publisher_session_path

      expect(page).to have_content(organisation.name)
      expect(page).to have_content(dsi_email_address)
      expect(current_path).to eq(organisation_path)
    end
  end

  context "with valid credentials that match a Local Authority" do
    let(:organisation) { create(:local_authority, local_authority_code: "100") }
    let(:publisher_preference) { instance_double(PublisherPreference) }

    before do
      allow(Rails.configuration).to receive(:enforce_local_authority_allowlist).and_return(true)
      allow(PublisherPreference).to receive(:find_by).and_return(publisher_preference)

      stub_authentication_step(school_urn: nil, la_code: organisation.local_authority_code, email: dsi_email_address)
      stub_authorisation_step
      stub_sign_in_with_multiple_organisations
    end

    it_behaves_like "a successful sign in"

    context "when user preferences have been set" do
      it "does not redirect the sign in page to the publisher preference page" do
        visit root_path
        sign_in_publisher

        expect(page).to have_content(organisation.name)
        expect(page).to have_content(dsi_email_address)
        expect(current_path).to eq(organisation_path)
      end
    end

    context "when user preferences have not been set" do
      let(:publisher_preference) { nil }

      it "redirects the sign in page to the publisher preference page" do
        visit root_path
        sign_in_publisher

        expect(current_path).to eq(new_publisher_preference_path)
      end
    end
  end

  context "with valid credentials but no authorisation" do
    before do
      create(:school, urn: "110627")
      stub_authentication_step(email: "another_email@example.com")
      stub_authorisation_step_with_not_found
    end

    it_behaves_like "a failed sign in", email: "another_email@example.com"
  end

  context "when there is was an error with DfE Sign-in" do
    before do
      stub_authentication_step
      stub_authorisation_step_with_external_error
    end

    it "raises an error" do
      visit root_path

      expect { sign_in_publisher }.to raise_error(Authorisation::ExternalServerError)
    end
  end

  context "when there is an Omniauth error" do
    before do
      OmniAuth.config.mock_auth[:dfe] = :invalid_client
    end

    it "logs an error to Rollbar and takes the user to the sign in page with an error message" do
      # OmniAuth doesn't mock the error being present, so allow `anything`
      expect(Rollbar).to receive(:error).with(anything, strategy: :dfe)

      sign_in_publisher

      expect(current_path).to eq(new_publisher_session_path)
      expect(page).to have_content(I18n.t("publishers.omniauth_callbacks.failure.message"))
    end
  end
end
