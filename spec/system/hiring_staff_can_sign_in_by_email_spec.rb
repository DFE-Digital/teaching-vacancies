require "rails_helper"

RSpec.describe "Hiring staff signing in with fallback email authentication" do
  before do
    allow(AuthenticationFallback).to receive(:enabled?) { true }
  end

  scenario "can reach email request page by nav-bar link" do
    visit root_path

    within(".govuk-header__navigation") { click_on(I18n.t("nav.sign_in")) }
    expect(page).to have_content(I18n.t("publishers.temp_login.heading"))
    expect(page).to have_content(I18n.t("publishers.temp_login.please_use_email"))
  end

  scenario "can reach email request page by sign in button" do
    visit root_path

    click_sign_in
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
        .with(login_key: login_key, email: publisher.email)
        .and_return(message_delivery)
    end

    context "when a publisher has multiple organisations" do
      let(:dsi_data) do
        { "school_urns" => [school.urn, other_school.urn], "trust_uids" => [trust.uid, "1623"], "la_codes" => [local_authority.local_authority_code] }
      end

      context "with LocalAuthorityAccessFeature enabled" do
        before do
          allow(LocalAuthorityAccessFeature).to receive(:enabled?).and_return(true)
          allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
        end

        let(:other_login_key) do
          publisher.emergency_login_keys.create(
            not_valid_after: Time.current + Publishers::SignIn::Email::SessionsController::EMERGENCY_LOGIN_KEY_DURATION,
          )
        end

        scenario "can sign in, choose an org, change org, sign out" do
          freeze_time do
            visit root_path
            click_sign_in

            # Expect to send an email
            expect(message_delivery).to receive(:deliver_later)

            fill_in "publisher[email]", with: publisher.email
            click_on "commit"
            expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

            # Expect that the link in the email goes to the landing page
            visit auth_email_choose_organisation_path(login_key: login_key.id)

            expect(page).to have_content("Choose your organisation")
            expect(page).not_to have_content(I18n.t("publishers.temp_login.denial.title"))
            expect(page).to have_content(other_school.name)
            expect(page).to have_content(trust.name)
            expect(page).to have_content(local_authority.name)
            click_on school.name

            expect(page).to have_text("Jobs at #{school.name}")
            expect { login_key.reload }.to raise_error ActiveRecord::RecordNotFound

            # Can switch organisations
            allow_any_instance_of(Publishers::SignIn::Email::SessionsController)
              .to receive(:generate_login_key)
              .with(publisher: publisher)
              .and_return(other_login_key)
            click_on I18n.t("publishers.organisations.change")
            click_on(trust.name)
            expect(page).to have_content("Jobs at #{trust.name}")
            expect { other_login_key.reload }.to raise_error ActiveRecord::RecordNotFound

            # Can sign out
            click_on(I18n.t("nav.sign_out"))

            within(".govuk-header__navigation") { expect(page).to have_content(I18n.t("nav.sign_in")) }
            expect(page).to have_content(I18n.t("messages.access.publisher_signed_out"))

            # Login link no longer works
            visit auth_email_choose_organisation_path(login_key: login_key.id)
            expect(page).to have_content("used")
            expect(page).not_to have_content("Choose your organisation")
          end
        end

        scenario "cannot sign in if key has expired" do
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

      context "with LocalAuthorityAccessFeature disabled" do
        scenario "the LA does not appear in the list of schools" do
          visit auth_email_choose_organisation_path(login_key: login_key.id)
          expect(page).to have_content("Choose your organisation")
          expect(page).not_to have_content(local_authority.name)
        end
      end
    end

    context "when a publisher has only one organisation" do
      context "organisation is a School" do
        let(:dsi_data) do
          { "school_urns" => [school.urn], "trust_uids" => [], "la_codes" => [] }
        end

        scenario "can sign in and bypass choice of org" do
          freeze_time do
            visit root_path
            click_sign_in

            # Expect to send an email
            expect(message_delivery).to receive(:deliver_later)

            fill_in "publisher[email]", with: publisher.email
            click_on "commit"
            expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

            # Expect that the link in the email goes to the landing page
            visit auth_email_choose_organisation_path(login_key: login_key.id)

            expect(page).not_to have_content("Choose your organisation")
            expect(page).to have_content("Jobs at #{school.name}")
            expect { login_key.reload }.to raise_error ActiveRecord::RecordNotFound
          end
        end
      end

      context "when the organisation is a Trust" do
        let(:dsi_data) do
          { "school_urns" => [], "trust_uids" => [trust.uid], "la_codes" => [] }
        end

        before do
          allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
        end

        scenario "can sign in and bypass choice of org" do
          freeze_time do
            visit root_path
            click_sign_in

            # Expect to send an email
            expect(message_delivery).to receive(:deliver_later)

            fill_in "publisher[email]", with: publisher.email
            click_on "commit"
            expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

            # Expect that the link in the email goes to the landing page
            visit auth_email_choose_organisation_path(login_key: login_key.id)

            expect(page).not_to have_content("Choose your organisation")
            expect(page).to have_content("Jobs at #{trust.name}")
            expect { login_key.reload }.to raise_error ActiveRecord::RecordNotFound
          end
        end
      end

      context "when the organisation is a Local Authority" do
        let(:dsi_data) do
          { "school_urns" => [], "trust_uids" => [], "la_codes" => [local_authority.local_authority_code] }
        end
        let(:la_publisher_allowed?) { true }

        context "with LocalAuthorityAccessFeature enabled" do
          before do
            allow(LocalAuthorityAccessFeature).to receive(:enabled?).and_return(true)
            allow(ALLOWED_LOCAL_AUTHORITIES)
              .to receive(:include?).with(local_authority.local_authority_code).and_return(la_publisher_allowed?)
            allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
          end

          scenario "can sign in and bypass choice of org" do
            freeze_time do
              visit root_path
              click_sign_in

              # Expect to send an email
              expect(message_delivery).to receive(:deliver_later)

              fill_in "publisher[email]", with: publisher.email
              click_on "commit"
              expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

              # Expect that the link in the email goes to the landing page
              visit auth_email_choose_organisation_path(login_key: login_key.id)

              expect(page).not_to have_content("Choose your organisation")
              expect(page).to have_content("Jobs in #{local_authority.name}")
              expect { login_key.reload }.to raise_error ActiveRecord::RecordNotFound
            end
          end

          context "when publisher oid is not in the allowed list" do
            let(:la_publisher_allowed?) { false }

            scenario "cannot sign in" do
              freeze_time do
                visit auth_email_choose_organisation_path(login_key: login_key.id)
                expect(page).to have_content "You are not authorised to log in"
              end
            end
          end
        end

        context "with LocalAuthorityAccessFeature disabled" do
          scenario "cannot sign in" do
            freeze_time do
              visit auth_email_choose_organisation_path(login_key: login_key.id)
              expect(page).to have_content "The login link you used is not associated with any organisations."
            end
          end
        end
      end
    end
  end

private

  def click_sign_in
    within(".signin") { click_on(I18n.t("buttons.sign_in")) }
  end
end
