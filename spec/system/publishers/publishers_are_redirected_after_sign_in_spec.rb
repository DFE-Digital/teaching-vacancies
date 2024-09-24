require "rails_helper"

RSpec.describe "Publishers are redirected after sign in" do
  let!(:organisation) { create(:school) }
  let(:publisher) { create(:publisher) }
  let(:vacancy) { create(:vacancy, publisher: publisher, organisations: [organisation]) }

  before { allow(AuthenticationFallback).to receive(:enabled?) { false } }

  around do |example|
    previous_default_mock_auth = OmniAuth.config.mock_auth[:default]
    previous_dfe_mock_auth = OmniAuth.config.mock_auth[:dfe]
    previous_test_mode_value = OmniAuth.config.test_mode

    stub_accepted_terms_and_conditions
    OmniAuth.config.test_mode = true
    stub_publisher_authentication_step(organisation_id: organisation.id, school_urn: organisation.urn)
    stub_publisher_authorisation_step(organisation_id: organisation.id)

    example.run

    OmniAuth.config.mock_auth[:default] = previous_default_mock_auth
    OmniAuth.config.mock_auth[:dfe] = previous_dfe_mock_auth
    OmniAuth.config.test_mode = previous_test_mode_value
  end

  context "when a publisher is redirected to the sign in page" do
    scenario "then the user is redirected back to the original page" do
      visit organisation_job_path(vacancy)
      expect(page).to have_text(I18n.t("publishers.sessions.new.sign_in.title"))

      sign_in_publisher

      expect(current_path).to eq(organisation_job_path(vacancy))
    end

    scenario "then goes to a different page and signs in" do
      visit organisation_job_path(vacancy)
      visit root_path

      sign_in_publisher(navigate: true)

      expect(current_path).to eq(publisher_root_path)
    end
  end

  context "when the organisation's profile is incomplete " do
    before { allow_any_instance_of(Organisation).to receive(:profile_complete?).and_return(false) }

    scenario "it redirects to the interstitial profile completion reminder page" do
      sign_in_publisher(navigate: true)

      expect(current_path).to eq(publishers_organisation_profile_incomplete_path(organisation))
      expect(page).to have_link(I18n.t("publishers.incomplete_profile.complete_link_text", organisation_type: :school), href: publishers_organisation_path(organisation))
    end
  end
end
