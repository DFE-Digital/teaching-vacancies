require "rails_helper"

RSpec.describe "Hiring staff accepts terms and conditions" do
  let(:school) { create(:school) }
  let(:oid) { "a-valid-oid" }
  let(:current_publisher) { Publisher.find_by(oid: oid) }
  before do
    stub_publishers_auth(urn: school.urn, oid: oid)
  end

  context "the user has not accepted the terms and conditions" do
    before { current_publisher.update(accepted_terms_at: nil) }

    scenario "they will see the terms and conditions" do
      visit organisation_path

      expect(page).to have_content(I18n.t("terms_and_conditions.please_accept"))
    end

    scenario "they can accept the terms and conditions" do
      visit terms_and_conditions_path

      expect(current_publisher).not_to be_accepted_terms_and_conditions

      check I18n.t("terms_and_conditions.label")
      click_on I18n.t("buttons.accept_and_continue")

      current_publisher.reload
      expect(page).to have_content(strip_tags(I18n.t("schools.jobs.index_html", organisation: school.name)))
      expect(current_publisher).to be_accepted_terms_and_conditions
    end

    scenario "an audit entry is logged when they accept" do
      visit terms_and_conditions_path

      expect(current_publisher).not_to be_accepted_terms_and_conditions

      check I18n.t("terms_and_conditions.label")
      click_on I18n.t("buttons.accept_and_continue")

      activity = current_publisher.activities.last
      expect(activity.key).to eq("user.terms_and_conditions.accept")
      expect(activity.session_id).to eq(oid)
    end

    scenario "an error is shown if they don’t accept" do
      visit terms_and_conditions_path

      expect(current_publisher).not_to be_accepted_terms_and_conditions

      click_on I18n.t("buttons.accept_and_continue")

      current_publisher.reload

      expect(page).to have_content("There is a problem")
      expect(current_publisher).not_to be_accepted_terms_and_conditions
    end

    context "signing out" do
      scenario "with authentication fallback" do
        allow(AuthenticationFallback).to receive(:enabled?).and_return(true)

        visit terms_and_conditions_path
        click_on(I18n.t("nav.sign_out"))

        expect(page).to have_content(I18n.t("messages.access.publisher_signed_out"))
      end

      scenario "without authentication fallback" do
        allow(AuthenticationFallback).to receive(:enabled?).and_return(false)

        visit terms_and_conditions_path

        click_on(I18n.t("nav.sign_out"))

        sign_out_via_dsi

        expect(page).to have_content(I18n.t("messages.access.publisher_signed_out"))
      end
    end
  end

  context "the user has accepted the terms and conditions" do
    scenario "they will not see the terms and conditions" do
      current_publisher.update(accepted_terms_at: Time.current)

      visit organisation_path

      expect(page).not_to have_content(I18n.t("terms_and_conditions.please_accept"))
    end
  end
end
