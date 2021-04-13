require "rails_helper"

RSpec.describe Publishers::JobApplicationMailer do
  let(:publisher) { create(:publisher, email: email) }
  let(:email) { "test@email.com" }
  let(:organisation) { create(:school) }
  let!(:vacancy) { create(:vacancy, publisher: publisher, organisation_vacancies_attributes: [{ organisation: organisation }]) }
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
    let(:mail) { described_class.applications_received(publisher: publisher) }
    let(:notify_template) { NOTIFY_PUBLISHER_JOB_APPLICATIONS_RECEIVED_TEMPLATE }

    it "sends a `publisher_applications_received` email" do
      expect(mail.subject).to eq(I18n.t("publishers.job_application_mailer.applications_received.subject", count: 2))
      expect(mail.to).to eq(["test@email.com"])
      expect(mail.body.encoded).to include(vacancy.job_title)
                               .and include(organisation_job_job_applications_url(vacancy))
                               .and include(I18n.t("publishers.job_application_mailer.applications_received.view_applications", count: 2))
    end

    it "triggers a `publisher_applications_received` email event" do
      expect { mail.deliver_now }
        .to have_triggered_event(:publisher_applications_received)
        .with_data(expected_data)
        .and_data(vacancies_job_applications: anything)
    end
  end
end
