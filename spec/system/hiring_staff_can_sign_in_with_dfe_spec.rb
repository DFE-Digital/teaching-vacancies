require "rails_helper"
require "message_encryptor"

RSpec.shared_examples "a successful sign in" do
  scenario "it signs in the user successfully" do
    visit root_path

    expect { sign_in_publisher }
      .to have_triggered_event(:publisher_sign_in_attempt)
      .with_base_data(user_anonymised_publisher_id: anonymised_form_of(user_oid))
      .and_data(success: "true", sign_in_type: "dsi")

    within(".govuk-header__navigation") { expect(page).to have_selector(:link_or_button, I18n.t("nav.sign_out")) }
    within(".govuk-header__navigation") { expect(page).to have_selector(:link_or_button, I18n.t("nav.school_page_link")) }
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
    within(".govuk-header__navigation") { expect(page).not_to have_content(I18n.t("nav.school_page_link")) }
  end
end

RSpec.describe "Hiring staff signing-in with DfE Sign In" do
  let(:user_oid) { "161d1f6a-44f1-4a1a-940d-d1088c439da7" }
  let(:dsi_email_address) { Faker::Internet.email }

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
      visit new_identifications_path

      expect(page).to have_content(organisation.name)
      expect(current_path).to eq(organisation_path)
    end
  end

  context "with DSI data including a school group (trust or local authority) that the school belongs to" do
    let(:dsi_data) { { "trust_uids" => %w[14323], "school_urns" => %w[246757 953341 122792], "la_codes" => %w[323] } }
    let!(:user) { create(:publisher, email: dsi_email_address, dsi_data: dsi_data) }
    let(:school) { create(:school, urn: "246757") }

    before do
      SchoolGroupMembership.create(school_group: school_group, school: school)

      stub_authentication_step(school_urn: "246757", email: dsi_email_address)
      stub_authorisation_step
      stub_sign_in_with_multiple_organisations

      visit root_path
      sign_in_publisher
    end

    context "with trust" do
      let(:school_group) { create(:trust, uid: "14323") }

      it "associates the user with the trust instead of the school" do
        expect(current_path).to eq(organisation_managed_organisations_path)
      end

      it "shows the trust name" do
        expect(page).to have_content(school_group.name)
      end
    end

    context "with local_authority" do
      let(:school_group) { create(:local_authority, local_authority_code: "323") }

      it "associates the user with the local_authority instead of the school" do
        expect(current_path).to eq(organisation_managed_organisations_path)
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

    context "when user preferences have been set" do
      it_behaves_like "a successful sign in"

      scenario "it redirects the sign in page to the SchoolGroup page" do
        visit root_path
        sign_in_publisher

        visit new_identifications_path
        expect(page).to have_content(organisation.name)
        expect(current_path).to eq(organisation_path)
      end
    end

    context "when user preferences have not been set" do
      let(:publisher_preference) { nil }

      scenario "it redirects the sign in page to the managed organisations user preference page" do
        visit root_path
        sign_in_publisher

        expect(current_path).to eq(organisation_managed_organisations_path)
      end
    end
  end

  context "with valid credentials that match a Local Authority" do
    let(:organisation) { create(:local_authority, local_authority_code: "100") }
    let(:publisher_preference) { instance_double(PublisherPreference) }
    let(:la_user_allowed?) { true }

    before do
      allow(Rails.configuration).to receive(:enforce_local_authority_allowlist).and_return(true)
      allow(Rails.configuration.allowed_local_authorities)
        .to receive(:include?).with(organisation.local_authority_code).and_return(la_user_allowed?)
      allow(PublisherPreference).to receive(:find_by).and_return(publisher_preference)

      stub_authentication_step(school_urn: nil, la_code: organisation.local_authority_code, email: dsi_email_address)
      stub_authorisation_step
      stub_sign_in_with_multiple_organisations
    end

    context "when user preferences have been set" do
      it_behaves_like "a successful sign in"

      scenario "it redirects the sign in page to the SchoolGroup page" do
        visit root_path
        sign_in_publisher

        visit new_identifications_path
        expect(current_path).to eq(organisation_path)
      end
    end

    context "when user preferences have not been set" do
      let(:publisher_preference) { nil }

      scenario "it redirects the sign in page to the managed organisations user preference page" do
        visit root_path
        sign_in_publisher

        expect(current_path).to eq(organisation_managed_organisations_path)
      end
    end

    context "when la_code is not in the allowed list" do
      let(:dsi_email_address) { "test@email.com" }
      let(:la_user_allowed?) { false }

      it_behaves_like "a failed sign in", user_id: "161d1f6a-44f1-4a1a-940d-d1088c439da7",
                                          la_code: "100",
                                          email: "test@email.com",
                                          not_authorised_message: "Hiring staff not authorised: 161d1f6a-44f1-4a1a-940d-d1088c439da7 for local authority: 100"
    end
  end

  context "with valid credentials but no authorisation" do
    before do
      stub_authentication_step(email: "another_email@example.com")
      stub_authorisation_step_with_not_found
    end

    it_behaves_like "a failed sign in", user_id: "161d1f6a-44f1-4a1a-940d-d1088c439da7",
                                        school_urn: "110627",
                                        email: "another_email@example.com",
                                        not_authorised_message: "Hiring staff not authorised: 161d1f6a-44f1-4a1a-940d-d1088c439da7 for school: 110627"
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
end
