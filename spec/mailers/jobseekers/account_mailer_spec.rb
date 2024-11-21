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
end
