require "rails_helper"

RSpec.describe "Publishers can sign in with fallback email authentication" do
  before { allow(AuthenticationFallback).to receive(:enabled?) { true } }

  it "can reach email authentication page" do
    visit root_path
    within(".navbar-component") { click_on I18n.t("buttons.sign_in") }
    click_on I18n.t("buttons.sign_in_publisher")

    expect(page).to have_content(I18n.t("publishers.temp_login.heading"))
    expect(page).to have_content(I18n.t("publishers.temp_login.please_use_email"))
  end

  context "publisher flow" do
    let(:school) { create(:school, name: "Some school") }
    let(:other_school) { create(:school, name: "Some other school") }
    let(:trust) { create(:trust) }
    let(:local_authority) { create(:local_authority, local_authority_code: "100") }
    let(:publisher) { create(:publisher, organisation_publishers_attributes: organisation_publishers, accepted_terms_at: 1.day.ago) }

    let(:login_key) do
      publisher.emergency_login_keys.create(
        not_valid_after: Time.current + Publishers::LoginKeysController::EMERGENCY_LOGIN_KEY_DURATION,
      )
    end

    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow_any_instance_of(Publishers::LoginKeysController)
        .to receive(:generate_login_key)
        .with(publisher: publisher)
        .and_return(login_key)
      allow(Publishers::AuthenticationFallbackMailer).to receive(:sign_in_fallback)
        .with(login_key_id: login_key.id, publisher: publisher)
        .and_return(message_delivery)
    end

    context "when a publisher has multiple organisations" do
      let(:organisation_publishers) do
        [
          { organisation: school },
          { organisation: other_school },
          { organisation: trust },
          { organisation: local_authority },
        ]
      end

      before { allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference)) }

      let(:other_login_key) do
        publisher.emergency_login_keys.create(
          not_valid_after: Time.current + Publishers::LoginKeysController::EMERGENCY_LOGIN_KEY_DURATION,
        )
      end

      it "can sign in, choose an org, sign out" do
        freeze_time do
          visit root_path
          within(".navbar-component") { click_on I18n.t("buttons.sign_in") }
          click_on I18n.t("buttons.sign_in_publisher")

          # Expect to send an email
          expect(message_delivery).to receive(:deliver_later)

          fill_in "publisher[email]", with: publisher.email
          click_on "commit"
          expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

          # Expect that the link in the email goes to the landing page
          visit login_key_path(login_key)

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

          within(".govuk-header__navigation") { expect(page).to have_content(I18n.t("buttons.sign_in")) }

          expect(page).to have_content(I18n.t("devise.sessions.signed_out"))

          # Login link no longer works
          visit login_key_path(login_key)
          expect(page).to have_content("used")
          expect(page).not_to have_content("Choose your organisation")
        end
      end

      it "cannot sign in if key has expired" do
        visit new_login_key_path
        fill_in "publisher[email]", with: publisher.email
        expect(message_delivery).to receive(:deliver_later)
        click_on "commit"
        travel 5.hours do
          visit login_key_path(login_key)
          expect(page).to have_content("expired")
          expect(page).not_to have_content("Choose your organisation")
        end
      end
    end

    context "when a publisher has only one organisation" do
      context "organisation is a School" do
        let(:organisation_publishers) { [{ organisation: school }] }

        it "can sign in and bypass choice of org" do
          freeze_time do
            visit root_path
            within(".navbar-component") { click_on I18n.t("buttons.sign_in") }
            click_on I18n.t("buttons.sign_in_publisher")

            # Expect to send an email
            expect(message_delivery).to receive(:deliver_later)

            fill_in "publisher[email]", with: publisher.email
            click_on "commit"
            expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

            # Expect that the link in the email goes to the landing page
            expect { visit login_key_path(login_key) }
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
        let(:organisation_publishers) { [{ organisation: trust }] }

        before { allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference)) }

        it "can sign in and bypass choice of org" do
          freeze_time do
            visit root_path
            within(".navbar-component") { click_on I18n.t("buttons.sign_in") }
            click_on I18n.t("buttons.sign_in_publisher")

            # Expect to send an email
            expect(message_delivery).to receive(:deliver_later)

            fill_in "publisher[email]", with: publisher.email
            click_on "commit"
            expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

            # Expect that the link in the email goes to the landing page
            expect { visit login_key_path(login_key) }
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
        let(:organisation_publishers) { [{ organisation: local_authority }] }

        before do
          allow(Rails.configuration).to receive(:enforce_local_authority_allowlist).and_return(true)
          allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
        end

        it "can sign in and bypass choice of org" do
          freeze_time do
            visit root_path
            within(".navbar-component") { click_on I18n.t("buttons.sign_in") }
            click_on I18n.t("buttons.sign_in_publisher")

            # Expect to send an email
            expect(message_delivery).to receive(:deliver_later)

            fill_in "publisher[email]", with: publisher.email
            click_on "commit"
            expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

            # Expect that the link in the email goes to the landing page
            expect { visit login_key_path(login_key) }
              .to have_triggered_event(:publisher_sign_in_attempt)
              .with_base_data(user_anonymised_publisher_id: anonymised_form_of(publisher.oid))
              .and_data(success: "true", sign_in_type: "email")

            expect(page).not_to have_content("Choose your organisation")
            expect(page).to have_content(local_authority.name)
            expect { login_key.reload }.to raise_error ActiveRecord::RecordNotFound
          end
        end
      end
    end
  end
end
