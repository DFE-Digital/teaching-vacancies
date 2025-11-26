require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe Publishers::JobApplicationMailer do
  let(:publisher) { create(:publisher, email: email) }
  let(:email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
  let(:organisation) { create(:school) }
  let!(:vacancy) { create(:vacancy, publisher: publisher, organisations: [organisation]) }
  let(:contact_email) { vacancy.contact_email }

  let(:expected_data) do
    {
      notify_template: notify_template,
      email_identifier: anonymised_form_of(email),
      user_anonymised_jobseeker_id: nil,
      user_anonymised_publisher_id: anonymised_form_of(publisher.oid),
    }
  end

  describe "#applications_received" do
    let!(:job_application1) { create(:job_application, :status_submitted, vacancy: vacancy, submitted_at: 1.day.ago) }
    let!(:job_application2) { create(:job_application, :status_submitted, vacancy: vacancy, submitted_at: 1.day.ago) }
    let!(:job_application3) { create(:job_application, :status_submitted, vacancy: vacancy, submitted_at: 2.day.ago) }
    let(:mail) { described_class.applications_received(contact_email: contact_email) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }

    it "sends a `publisher_applications_received` email" do
      expect(mail.subject).to eq(I18n.t("publishers.job_application_mailer.applications_received.subject", count: 2))
      expect(mail.to).to eq([email])
      expect(mail.body.encoded).to include(vacancy.job_title)
                               .and include(organisation_job_job_applications_url(vacancy.id))
                               .and include(I18n.t("publishers.job_application_mailer.applications_received.title"))
                               .and include(I18n.t("publishers.job_application_mailer.applications_received.view_applications", count: 2, job_title: vacancy.job_title))
    end

    it "triggers a `publisher_applications_received` email event", :dfe_analytics do
      mail.deliver_now
      expect(:publisher_applications_received).to have_been_enqueued_as_analytics_event(with_data: %i[uid notify_template]) # rubocop:disable RSpec/ExpectActual
    end
  end
end
