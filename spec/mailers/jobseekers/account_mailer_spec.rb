require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe Jobseekers::AccountMailer do
  let(:jobseeker) { create(:jobseeker, email: email) }
  let(:email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
  let(:token) { "some-special-token" }

  let(:expected_data) do
    {
      notify_template: notify_template,
      email_identifier: anonymised_form_of(email),
      user_anonymised_jobseeker_id: anonymised_form_of(jobseeker.id),
      user_anonymised_publisher_id: nil,
    }
  end

  describe "#account_closed" do
    let(:mail) { described_class.account_closed(jobseeker) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }

    it "sends an `account_closed` email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.account_mailer.account_closed.subject"))
      expect(mail.to).to eq([email])
      expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.account_closed.heading"))
    end

    it "triggers a `jobseeker_account_closed` email event" do
      mail.deliver_now
      expect(:jobseeker_account_closed).to have_been_enqueued_as_analytics_events
    end
  end

  describe "#confirmation_instructions" do
    let(:mail) { described_class.confirmation_instructions(jobseeker, token) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }

    context "when the jobseeker is not pending reconfirmation" do
      before { jobseeker.confirm }

      it "sends a `jobseeker_confirmation_instructions` email" do
        expect(mail.subject).to eq(I18n.t("jobseekers.account_mailer.confirmation_instructions.subject"))
        expect(mail.to).to eq([email])
        expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.confirmation_instructions.body"))
                                 .and include(jobseeker_confirmation_path(confirmation_token: token))
      end

      it "triggers a `jobseeker_confirmation_instructions` email event" do
        mail.deliver_now
        expect(:jobseeker_confirmation_instructions).to have_been_enqueued_as_analytics_events
      end
    end

    context "when the jobseeker is being reminded to confirm" do
      let(:email_address) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
      let(:jobseeker) { create(:jobseeker, email: email_address, confirmation_token: token, unconfirmed_email: email_address, confirmed_at: nil, confirmation_sent_at: 18.hours.ago) }

      it "sends a `jobseeker_confirmation_instructions` email" do
        expect(mail.subject).to eq(I18n.t("jobseekers.account_mailer.confirmation_instructions.reminder.subject"))
        expect(mail.to).to eq([email_address])
        expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.confirmation_instructions.body"))
                                 .and include(jobseeker_confirmation_path(confirmation_token: token))
      end

      it "triggers a `jobseeker_confirmation_instructions` email event" do
        mail.deliver_now
        expect(:jobseeker_confirmation_instructions).to have_been_enqueued_as_analytics_events
      end
    end
  end

  describe "#email_changed" do
    let(:mail) { described_class.email_changed(jobseeker) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }

    it "sends a `jobseeker_email_changed` email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.account_mailer.email_changed.subject"))
      expect(mail.to).to eq([email])
      expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.email_changed.heading"))
    end

    it "triggers a `jobseeker_email_changed` email event" do
      mail.deliver_now
      expect(:jobseeker_email_changed).to have_been_enqueued_as_analytics_events
    end
  end

  describe "#inactive_account" do
    let(:mail) { described_class.inactive_account(jobseeker) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }

    it "sends an `inactive_account` email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.account_mailer.inactive_account.subject"))
      expect(mail.to).to eq([email])
      expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.inactive_account.subject"))
      expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.inactive_account.intro"))
      expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.inactive_account.explanation"))
      expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.inactive_account.reactivate", date: 2.weeks.from_now.to_date.to_formatted_s(:day_month)))
      expect(mail.body.encoded).to include(new_jobseeker_session_path)
    end

    it "triggers a `jobseeker_inactive_account` email event" do
      mail.deliver_now
      expect(:jobseeker_inactive_account).to have_been_enqueued_as_analytics_events
    end
  end

  describe "#reset_password_instructions" do
    let(:mail) { described_class.reset_password_instructions(jobseeker, token) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }

    it "sends a `jobseeker_reset_password_instructions` email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.account_mailer.reset_password_instructions.subject"))
      expect(mail.to).to eq([email])
      expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.reset_password_instructions.heading"))
                               .and include(edit_jobseeker_password_path(reset_password_token: token))
    end

    it "triggers a `jobseeker_reset_passwords_instructions` email event" do
      mail.deliver_now
      expect(:jobseeker_reset_password_instructions).to have_been_enqueued_as_analytics_events
    end
  end

  describe "#unlock_instructions" do
    let(:mail) { described_class.unlock_instructions(jobseeker, token) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }

    it "sends a `jobseeker_unlock_instructions` email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.account_mailer.unlock_instructions.subject"))
      expect(mail.to).to eq([email])
      expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.unlock_instructions.heading"))
                               .and include(jobseeker_unlock_path(unlock_token: token))
    end

    it "triggers a `jobseeker_unlock_instructions` email event" do
      mail.deliver_now
      expect(:jobseeker_unlock_instructions).to have_been_enqueued_as_analytics_events
    end
  end
end
