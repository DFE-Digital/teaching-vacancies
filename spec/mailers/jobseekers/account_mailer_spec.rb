require "rails_helper"

RSpec.describe Jobseekers::AccountMailer do
  let(:jobseeker) { create(:jobseeker, email: email) }
  let(:email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }

  describe "#account_closed" do
    let(:mail) { described_class.account_closed(jobseeker) }

    it "sends an `account_closed` email" do
      expect(mail.to).to eq([email])
    end

    it "triggers a `jobseeker_account_closed` email event", :dfe_analytics do
      mail.deliver_now
      expect(:jobseeker_account_closed).to have_been_enqueued_as_analytics_event(with_data: %i[uid notify_template]) # rubocop:disable RSpec/ExpectActual
    end
  end

  describe "#inactive_account" do
    let(:mail) { described_class.inactive_account(jobseeker) }

    it "sends an `inactive_account` email" do
      expect(mail.to).to eq([email])
      expect(mail.personalisation).to include(sign_in_link: new_jobseeker_session_url, date: 2.weeks.from_now.to_date.to_fs(:day_month))
    end

    it "triggers a `jobseeker_inactive_account` email event", :dfe_analytics do
      mail.deliver_now
      expect(:jobseeker_inactive_account).to have_been_enqueued_as_analytics_event(with_data: %i[uid notify_template]) # rubocop:disable RSpec/ExpectActual
    end
  end
end
