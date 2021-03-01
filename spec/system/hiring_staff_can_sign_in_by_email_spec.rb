require "rails_helper"

RSpec.describe "Hiring staff signing in with fallback email authentication" do
  before { allow(AuthenticationFallback).to receive(:enabled?) { true } }

  it "can reach email request page by nav-bar link" do
    visit root_path

    within(".govuk-header__navigation") { click_on(I18n.t("nav.for_schools")) }
    expect(page).to have_content(I18n.t("publishers.temp_login.heading"))
    expect(page).to have_content(I18n.t("publishers.temp_login.please_use_email"))
  end

  it "can reach email request page by for schools button" do
    visit root_path

    click_for_schools
    expect(page).to have_content(I18n.t("publishers.temp_login.heading"))
    expect(page).to have_content(I18n.t("publishers.temp_login.please_use_email"))
  end

  context "publisher flow" do
    let(:school) { create(:school, name: "Some school") }
    let(:other_school) { create(:school, name: "Some other school") }
    let(:trust) { create(:trust) }
    let(:local_authority) { create(:local_authority, local_authority_code: "100") }
    let(:publisher) { create(:publisher, dsi_data: dsi_data, accepted_terms_at: 1.day.ago) }

    let(:login_key) do
      publisher.emergency_login_keys.create(
        not_valid_after: Time.current + Publishers::SignIn::Email::SessionsController::EMERGENCY_LOGIN_KEY_DURATION,
      )
    end

    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow_any_instance_of(Publishers::SignIn::Email::SessionsController)
        .to receive(:generate_login_key)
        .with(publisher: publisher)
        .and_return(login_key)
      allow(AuthenticationFallbackMailer).to receive(:sign_in_fallback)
        .with(login_key: login_key, publisher: publisher)
        .and_return(message_delivery)
    end

    context "when a publisher has multiple organisations" do
      let(:dsi_data) do
        {
          "school_urns" => [school.urn, other_school.urn],
          "trust_uids" => [trust.uid, "1623"],
          "la_codes" => [local_authority.local_authority_code],
        }
      end

      before { allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference)) }

      let(:other_login_key) do
        publisher.emergency_login_keys.create(
          not_valid_after: Time.current + Publishers::SignIn::Email::SessionsController::EMERGENCY_LOGIN_KEY_DURATION,
        )
      end

      it "can sign in, choose an org, change org, sign out" do
        freeze_time do
          visit root_path
          click_for_schools

          # Expect to send an email
          expect(message_delivery).to receive(:deliver_later)

          fill_in "publisher[email]", with: publisher.email
          click_on "commit"
          expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

          # Expect that the link in the email goes to the landing page
          visit auth_email_choose_organisation_path(login_key: login_key.id)

          expect(page).to have_content("Choose your organisation")
          expect(page).not_to have_content(I18n.t("publishers.temp_login.choose_organisation.denial.title"))
          expect(page).to have_content(other_school.name)
          expect(page).to have_content(trust.name)
          expect(page).to have_content(local_authority.name)
          expect { click_on school.name }
            .to have_triggered_event(:publisher_sign_in_attempt)
            .with_base_data(user_anonymised_publisher_id: anonymised_form_of(publisher.oid))
            .and_data(success: "true", sign_in_type: "email")

          expect(page).to have_content(school.name)
          expect { login_key.reload }.to raise_error ActiveRecord::RecordNotFound

          # Can sign out
          click_on(I18n.t("nav.sign_out"))

          within(".govuk-header__navigation") { expect(page).to have_content(I18n.t("nav.for_schools")) }
          expect(page).to have_content(I18n.t("messages.access.publisher_signed_out"))

          # Login link no longer works
          visit auth_email_choose_organisation_path(login_key: login_key.id)
          expect(page).to have_content("used")
          expect(page).not_to have_content("Choose your organisation")
        end
      end

      it "cannot sign in if key has expired" do
        visit new_identifications_path
        fill_in "publisher[email]", with: publisher.email
        expect(message_delivery).to receive(:deliver_later)
        click_on "commit"
        travel 5.hours do
          visit auth_email_choose_organisation_path(login_key: login_key.id)
          expect(page).to have_content("expired")
          expect(page).not_to have_content("Choose your organisation")
        end
      end
    end

    context "when a publisher has only one organisation" do
      context "organisation is a School" do
        let(:dsi_data) { { "school_urns" => [school.urn], "trust_uids" => [], "la_codes" => [] } }

        it "can sign in and bypass choice of org" do
          freeze_time do
            visit root_path
            click_for_schools

            # Expect to send an email
            expect(message_delivery).to receive(:deliver_later)

            fill_in "publisher[email]", with: publisher.email
            click_on "commit"
            expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

            # Expect that the link in the email goes to the landing page
            expect { visit auth_email_choose_organisation_path(login_key: login_key.id) }
              .to have_triggered_event(:publisher_sign_in_attempt)
              .with_base_data(user_anonymised_publisher_id: anonymised_form_of(publisher.oid))
              .and_data(success: "true", sign_in_type: "email")

            expect(page).not_to have_content("Choose your organisation")
            expect(page).to have_content(school.name)
            expect { login_key.reload }.to raise_error ActiveRecord::RecordNotFound
          end
        end
      end

      context "when the organisation is a Trust" do
        let(:dsi_data) { { "school_urns" => [], "trust_uids" => [trust.uid], "la_codes" => [] } }

        before { allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference)) }

        it "can sign in and bypass choice of org" do
          freeze_time do
            visit root_path
            click_for_schools

            # Expect to send an email
            expect(message_delivery).to receive(:deliver_later)

            fill_in "publisher[email]", with: publisher.email
            click_on "commit"
            expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

            # Expect that the link in the email goes to the landing page
            expect { visit auth_email_choose_organisation_path(login_key: login_key.id) }
              .to have_triggered_event(:publisher_sign_in_attempt)
              .with_base_data(user_anonymised_publisher_id: anonymised_form_of(publisher.oid))
              .and_data(success: "true", sign_in_type: "email")

            expect(page).not_to have_content("Choose your organisation")
            expect(page).to have_content(trust.name)
            expect { login_key.reload }.to raise_error ActiveRecord::RecordNotFound
          end
        end
      end

      context "when the organisation is a Local Authority" do
        let(:dsi_data) { { "school_urns" => [], "trust_uids" => [], "la_codes" => [local_authority.local_authority_code] } }
        let(:la_publisher_allowed?) { true }

        before do
          allow(Rails.configuration).to receive(:enforce_local_authority_allowlist).and_return(true)
          allow(Rails.configuration.allowed_local_authorities)
            .to receive(:include?).with(local_authority.local_authority_code).and_return(la_publisher_allowed?)
          allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
        end

        it "can sign in and bypass choice of org" do
          freeze_time do
            visit root_path
            click_for_schools

            # Expect to send an email
            expect(message_delivery).to receive(:deliver_later)

            fill_in "publisher[email]", with: publisher.email
            click_on "commit"
            expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

            # Expect that the link in the email goes to the landing page
            expect { visit auth_email_choose_organisation_path(login_key: login_key.id) }
              .to have_triggered_event(:publisher_sign_in_attempt)
              .with_base_data(user_anonymised_publisher_id: anonymised_form_of(publisher.oid))
              .and_data(success: "true", sign_in_type: "email")

            expect(page).not_to have_content("Choose your organisation")
            expect(page).to have_content(local_authority.name)
            expect { login_key.reload }.to raise_error ActiveRecord::RecordNotFound
          end
        end

        context "when publisher oid is not in the allowed list" do
          let(:la_publisher_allowed?) { false }

          it "cannot sign in" do
            freeze_time do
              expect { visit auth_email_choose_organisation_path(login_key: login_key.id) }
                .to have_triggered_event(:publisher_sign_in_attempt)
                .with_base_data(user_anonymised_publisher_id: anonymised_form_of(publisher.oid))
                .and_data(success: "false", sign_in_type: "email")

              expect(page).to have_content "You are not authorised to log in"
            end
          end
        end
      end
    end
  end

  private

  def click_for_schools
    within(".govuk-header__navigation") { click_on(I18n.t("nav.for_schools")) }
  end
end
