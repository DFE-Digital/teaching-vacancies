require "rails_helper"

RSpec.describe Jobseekers::AccountMailer do
  let(:jobseeker) { create(:jobseeker, email: email) }
  let(:email) { "test@email.com" }
  let(:token) { "some-special-token" }

  let(:expected_data) do
    {
      notify_template: notify_template,
      email_identifier: anonymised_form_of(email),
      user_anonymised_jobseeker_id: anonymised_form_of(jobseeker.id),
      user_anonymised_publisher_id: nil,
    }
  end

  describe "#confirmation_instructions" do
    let(:mail) { described_class.confirmation_instructions(jobseeker, token) }
    let(:notify_template) { NOTIFY_JOBSEEKER_CONFIRMATION_TEMPLATE }

    context "when the jobseeker is pending reconfirmation" do
      let(:email) { "unconfirmed@email.com" }
      let(:jobseeker) { create(:jobseeker, email: "test@email.com", unconfirmed_email: email) }

      before { allow(jobseeker).to receive(:pending_reconfirmation?).and_return(true) }

      it "sends confirmation_instructions email" do
        expect(mail.subject).to eq(I18n.t("jobseekers.account_mailer.confirmation_instructions.reconfirmation.subject"))
        expect(mail.to).to eq(["unconfirmed@email.com"])
        expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.confirmation_instructions.reconfirmation.heading"))
                                 .and include(jobseeker_confirmation_path(confirmation_token: token))
      end

      it "triggers a `jobseeker_confirmation_instructions` email event" do
        expect { mail.deliver_now }.to have_triggered_event(:jobseeker_confirmation_instructions)
          .with_data(expected_data).and_data(previous_email_identifier: anonymised_form_of("test@email.com"))
      end
    end

    context "when the jobseeker is not pending reconfirmation" do
      before { allow(jobseeker).to receive(:pending_reconfirmation?).and_return(false) }

      it "sends a `jobseeker_confirmation_instructions` email" do
        expect(mail.subject).to eq(I18n.t("jobseekers.account_mailer.confirmation_instructions.subject"))
        expect(mail.to).to eq(["test@email.com"])
        expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.confirmation_instructions.heading"))
                                 .and include(jobseeker_confirmation_path(confirmation_token: token))
      end

      it "triggers a `jobseeker_confirmation_instructions` email event" do
        expect { mail.deliver_now }.to have_triggered_event(:jobseeker_confirmation_instructions).with_data(expected_data)
      end
    end
  end

  describe "#email_changed" do
    let(:mail) { described_class.email_changed(jobseeker) }
    let(:notify_template) { NOTIFY_JOBSEEKER_EMAIL_CHANGED_TEMPLATE }

    it "sends a `jobseeker_email_changed` email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.account_mailer.email_changed.subject"))
      expect(mail.to).to eq(["test@email.com"])
      expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.email_changed.heading"))
    end

    it "triggers a `jobseeker_email_changed` email event" do
      expect { mail.deliver_now }.to have_triggered_event(:jobseeker_email_changed).with_data(expected_data)
    end
  end

  describe "#reset_password_instructions" do
    let(:mail) { described_class.reset_password_instructions(jobseeker, token) }
    let(:notify_template) { NOTIFY_JOBSEEKER_RESET_PASSWORD_TEMPLATE }

    it "sends a `jobseeker_reset_password_instructions` email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.account_mailer.reset_password_instructions.subject"))
      expect(mail.to).to eq(["test@email.com"])
      expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.reset_password_instructions.heading"))
                               .and include(edit_jobseeker_password_path(reset_password_token: token))
    end

    it "triggers a `jobseeker_reset_passwords_instructions` email event" do
      expect { mail.deliver_now }.to have_triggered_event(:jobseeker_reset_password_instructions).with_data(expected_data)
    end
  end

  describe "#unlock_instructions" do
    let(:mail) { described_class.unlock_instructions(jobseeker, token) }
    let(:notify_template) { NOTIFY_JOBSEEKER_LOCKED_ACCOUNT_TEMPLATE }

    it "sends a `jobseeker_unlock_instructions` email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.account_mailer.unlock_instructions.subject"))
      expect(mail.to).to eq(["test@email.com"])
      expect(mail.body.encoded).to include(I18n.t("jobseekers.account_mailer.unlock_instructions.heading"))
                               .and include(jobseeker_unlock_path(unlock_token: token))
    end

    it "triggers a `jobseeker_unlock_instructions` email event" do
      expect { mail.deliver_now }.to have_triggered_event(:jobseeker_unlock_instructions).with_data(expected_data)
    end
  end
end
