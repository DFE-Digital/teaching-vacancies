require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe Publishers::JobApplicationDataExpiryMailer do
  let(:email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
  let(:mail) { described_class.with(params).job_application_data_expiry }
  let(:organisation) { create(:school) }
  let(:params) { { vacancy: vacancy, publisher: publisher } }
  let(:publisher) { create(:publisher, email: email) }
  let(:vacancy) { create(:vacancy, publisher: publisher, organisations: [organisation]) }
  let(:vacancy_data_expiration_date) { (vacancy.expires_at + 1.year).to_date }

  describe "#job_application_data_expiry" do
    it "sends a `job_application_data_expiry` email" do
      expect(mail.to).to eq([email])
      expect(mail.personalisation)
        .to include(job_title: vacancy.job_title, expiration_date: vacancy_data_expiration_date,
                    published_month: vacancy.publish_on.to_fs(:month_year),
                    view_applications_link: organisation_job_job_applications_url(vacancy.id))
    end

    it "triggers a `publisher_job_application_data_expiry` email event", :dfe_analytics do
      mail.deliver_now
      expect(:publisher_job_application_data_expiry).to have_been_enqueued_as_analytics_event(with_data: %i[uid notify_template]) # rubocop:disable RSpec/ExpectActual
    end
  end
end
