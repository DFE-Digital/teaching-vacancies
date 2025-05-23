require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.shared_examples "a successful Publisher sign in" do
  before do
    visit new_publisher_session_path
  end

  scenario "it signs in the user successfully", :dfe_analytics do
    sign_in_publisher
    expect(:successful_publisher_sign_in_attempt).to have_been_enqueued_as_analytics_event(with_data: { sign_in_type: "dsi" }) # rubocop:disable RSpec/ExpectActual

    within(".govuk-header__navigation") { expect(page).to have_selector(:link_or_button, I18n.t("nav.sign_out")) }
    within(".govuk-header__navigation") { expect(page).to have_selector(:link_or_button, I18n.t("nav.manage_jobs")) }
  end
end

RSpec.shared_examples "a failed Publisher sign in" do |options|
  scenario "it does not sign-in the user, and tells the user what to do", :dfe_analytics do
    visit new_publisher_session_path
    sign_in_publisher

    expect(:failed_dsi_sign_in_attempt).to have_been_enqueued_as_analytics_event(with_data: { sign_in_type: "dsi" }) # rubocop:disable RSpec/ExpectActual

    expect(page).to have_content(/The email you're signed in with isn't authorised to list jobs for this school/i)
    expect(page).to have_content(options[:email])
    within(".govuk-header__navigation") { expect(page).to have_no_content(I18n.t("nav.manage_jobs")) }
  end
end

RSpec.describe "Publisher authentication" do
  describe "sign-in with DfE Sign In" do
    let(:user_oid) { "161d1f6a-44f1-4a1a-940d-d1088c439da7" }
    let(:dsi_email_address) { Faker::Internet.email(domain: "example.com") }

    before do
      allow(AuthenticationFallback).to receive(:enabled?).and_return(false)
      stub_accepted_terms_and_conditions
      OmniAuth.config.test_mode = true
    end

    after do
      OmniAuth.config.mock_auth[:default] = nil
      OmniAuth.config.mock_auth[:dfe] = nil
      OmniAuth.config.test_mode = false
    end

    context "when the hiring staff is not signed in" do
      scenario "it displays the hiring staff CTA section with the text for when they are signed out" do
        visit root_path

        expect(page).to have_content(I18n.t("home.index.publisher_section.title"))
        expect(page).to have_content(I18n.t("home.index.publisher_section.signed_out.description_html"))
        expect(page).to have_link(I18n.t("home.index.publisher_section.signed_out.link_text.sign_in"), href: publishers_sign_in_path)
        expect(page).to have_link(I18n.t("home.index.publisher_section.signed_out.link_text.create_account"), href: page_path("dsi-account-request"))
      end
    end

    context "with valid credentials that match a school" do
      let!(:organisation) { create(:school, :with_image, urn: "110627") }

      before do
        stub_publisher_authentication_step email: dsi_email_address
        stub_publisher_authorisation_step
        stub_sign_in_with_multiple_organisations
      end

      it_behaves_like "a successful Publisher sign in"

      scenario "it redirects the sign in page to the school page" do
        sign_in_publisher(navigate: true)
        visit new_publisher_session_path

        expect(page).to have_content(organisation.name)
        expect(page).to have_current_path(publisher_root_path, ignore_query: true)
      end

      scenario "it displays the hiring staff CTA section with the text for when they are signed in" do
        sign_in_publisher(navigate: true)
        visit root_path

        expect(page).to have_content(I18n.t("home.index.publisher_section.title"))
        expect(page).to have_link(I18n.t("home.index.publisher_section.signed_in.link_text.manage_jobs"), href: organisation_jobs_with_type_path)
        click_on I18n.t("buttons.create_job")
        expect(page).to have_current_path(organisation_jobs_start_path, ignore_query: true)
        click_on I18n.t("buttons.create_job")
        expect(page).to have_current_path(reminder_publishers_new_features_path, ignore_query: true)
      end

      context "when navigating to support user login page" do
        it "does not redirect to support user dashboard" do
          sign_in_publisher(navigate: true)
          visit new_support_user_session_path

          # rubocop:disable Capybara/NegationMatcherAfterVisit
          expect(page).to have_no_current_path(support_user_root_path, ignore_query: true)
          # rubocop:enable Capybara/NegationMatcherAfterVisit
        end
      end
    end

    context "with DSI data including a school group (trust or local authority) that the school belongs to" do
      let!(:publisher) { Publisher.find_by(oid: user_oid) }
      let!(:school) { create(:school, :profile_incomplete, urn: "246757") }

      before do
        publisher.update! organisations: [school, school_group]
        stub_publisher_authentication_step(school_urn: "246757", email: dsi_email_address)
        stub_publisher_authorisation_step
        stub_sign_in_with_multiple_organisations

        visit new_publisher_session_path
        sign_in_publisher
      end

      context "with trust" do
        let!(:school_group) { create(:trust, uid: "14323", schools: [school]) }

        it "associates the user with the trust instead of the school" do
          click_on I18n.t("publishers.incomplete_profile.skip_to_link_text")
          expect(page).to have_current_path(organisation_jobs_path, ignore_query: true)
          expect(page).to have_content(school_group.name)
        end
      end

      context "with local_authority" do
        let!(:school_group) { create(:local_authority, local_authority_code: "323", schools: [school]) }

        it "associates the user with the local_authority instead of the school" do
          expect(page).to have_current_path(new_publishers_publisher_preference_path, ignore_query: true)
        end

        it "shows the local_authority name" do
          expect(page).to have_content(school_group.name)
        end
      end
    end

    context "with valid credentials that match a Trust" do
      let(:organisation) { create(:trust, :profile_incomplete) }

      before do
        stub_publisher_authentication_step(school_urn: nil, trust_uid: organisation.uid, email: dsi_email_address)
        stub_publisher_authorisation_step
        stub_sign_in_with_multiple_organisations
      end

      it_behaves_like "a successful Publisher sign in"

      scenario "it redirects the sign in page to the trust page" do
        visit new_publisher_session_path
        sign_in_publisher
        visit new_publisher_session_path

        click_on I18n.t("publishers.incomplete_profile.skip_to_link_text")
        expect(page).to have_content(organisation.name)
        expect(page).to have_current_path(organisation_jobs_path, ignore_query: true)
      end
    end

    context "with valid credentials that match a Local Authority" do
      let(:organisation) { create(:local_authority, local_authority_code: "100") }

      before do
        allow(Rails.configuration).to receive(:enforce_local_authority_allowlist).and_return(true)
        allow(PublisherPreference).to receive(:find_by).and_return(publisher_preference)

        stub_publisher_authentication_step(school_urn: nil, la_code: organisation.local_authority_code, email: dsi_email_address)
        stub_publisher_authorisation_step
        stub_sign_in_with_multiple_organisations
      end

      context "when user preferences have been set" do
        let(:publisher_preference) { instance_double(PublisherPreference) }

        it_behaves_like "a successful Publisher sign in"

        it "does not redirect the sign in page to the publisher preference page" do
          visit new_publisher_session_path
          sign_in_publisher

          expect(page).to have_content(organisation.name)
          expect(page).to have_current_path(publisher_root_path, ignore_query: true)
        end
      end

      context "when user preferences have not been set" do
        let(:publisher_preference) { nil }

        it "redirects the sign in page to the publisher preference page" do
          visit new_publisher_session_path
          sign_in_publisher

          expect(page).to have_current_path(new_publishers_publisher_preference_path, ignore_query: true)
        end
      end
    end

    context "with valid credentials but no authorisation" do
      before do
        create(:school, urn: "110627")
        stub_publisher_authentication_step(email: "another_email@example.com")
        stub_publisher_authorisation_step_with_not_found
      end

      it_behaves_like "a failed Publisher sign in", email: "another_email@example.com"
    end

    context "when there is was an error with DfE Sign-in" do
      before do
        stub_publisher_authentication_step
        stub_publisher_authorisation_step_with_external_error
      end

      it "raises an error" do
        visit new_publisher_session_path

        expect { sign_in_publisher }.to raise_error(Authorisation::ExternalServerError)
      end
    end

    context "when there is an Omniauth error" do
      before do
        OmniAuth.config.mock_auth[:dfe] = :invalid_client
      end

      it "logs an error to Sentry and takes the user to the sign in page with an error message" do
        expect(Sentry).to receive(:capture_message)

        sign_in_publisher(navigate: true)

        expect(page).to have_current_path(new_publisher_session_path, ignore_query: true)
        expect(page).to have_content(I18n.t("omniauth_callbacks.failure.message"))
      end
    end
  end

  describe "sign-out" do
    let(:publisher) { create(:publisher) }
    let(:school) { create(:school) }

    scenario "as an authenticated user" do
      login_publisher(publisher: publisher, organisation: school)

      visit root_path

      click_on(I18n.t("nav.sign_out"))

      within(".govuk-header__navigation") { expect(page).to have_content(I18n.t("buttons.sign_in")) }
      expect(page).to have_content(I18n.t("devise.sessions.signed_out"))
    end
  end
end
