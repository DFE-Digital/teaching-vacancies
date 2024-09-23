require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe Jobseekers::JobApplicationMailer do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { build(:school) }
  let(:vacancy) { build(:vacancy, organisations: [organisation]) }
  let(:contact_email) { vacancy.contact_email }

  let(:expected_data) do
    {
      notify_template: notify_template,
      email_identifier: anonymised_form_of(email),
      user_anonymised_jobseeker_id: anonymised_form_of(jobseeker.id),
      user_anonymised_publisher_id: nil,
    }
  end

  describe "#application_shortlisted" do
    let(:job_application) { build(:job_application, :status_shortlisted, jobseeker: jobseeker, vacancy: vacancy) }
    let(:mail) { described_class.application_shortlisted(job_application) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }

    it "sends a `jobseeker_application_shortlisted` email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.job_application_mailer.application_shortlisted.subject"))
      expect(mail.to).to eq([jobseeker.email])
      expect(mail.body.encoded).to include(I18n.t("jobseekers.job_application_mailer.application_shortlisted.heading", job_title: vacancy.job_title, organisation_name: organisation.name))
                                   .and include(I18n.t("jobseekers.job_application_mailer.shared.more_info.description",
                                                       email: "[#{contact_email}](mailto:#{contact_email})"))
    end

    it "triggers a `jobseeker_application_shortlisted` email event" do
      mail.deliver_now
      expect(:jobseeker_application_shortlisted).to have_been_enqueued_as_analytics_events
    end
  end

  describe "#application_submitted" do
    let(:job_application) { build(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }
    let(:mail) { described_class.application_submitted(job_application) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }

    it "sends a `jobseeker_application_submitted` email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.job_application_mailer.application_submitted.subject"))
      expect(mail.to).to eq([jobseeker.email])
      expect(mail.body.encoded).to include(I18n.t("jobseekers.job_application_mailer.application_submitted.heading",
                                                  organisation_name: organisation.name))
                               .and include(I18n.t("jobseekers.job_application_mailer.shared.more_info.description",
                                                   email: "[#{contact_email}](mailto:#{contact_email})"))
    end

    it "triggers a `jobseeker_application_submitted` email event" do
      mail.deliver_now
      expect(:jobseeker_application_submitted).to have_been_enqueued_as_analytics_events
    end
  end

  describe "#application_unsuccessful" do
    let(:job_application) { build(:job_application, :status_unsuccessful, jobseeker: jobseeker, vacancy: vacancy) }
    let(:mail) { described_class.application_unsuccessful(job_application) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }

    it "sends a `jobseeker_application_unsuccessful` email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.job_application_mailer.application_unsuccessful.subject"))
      expect(mail.to).to eq([jobseeker.email])
      expect(mail.body.encoded).to include(I18n.t("jobseekers.job_application_mailer.application_unsuccessful.heading"))
                               .and include(I18n.t("jobseekers.job_application_mailer.shared.more_info.description",
                                                   email: "[#{contact_email}](mailto:#{contact_email})"))
    end

    it "triggers a `jobseeker_application_unsuccessful` email event" do
      mail.deliver_now
      expect(:jobseeker_application_unsuccessful).to have_been_enqueued_as_analytics_events
    end
  end

  describe "#job_listing_ended_early" do
    let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }
    let(:mail) { described_class.job_listing_ended_early(job_application, vacancy) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }

    it "sends a `jobseeker_job_listing_ended_early` email" do
      expect(mail.subject).to eq("Update on #{vacancy.job_title} at #{vacancy.organisation_name}")
      expect(mail.to).to eq([jobseeker.email])
      expect(mail.body.encoded).to include(I18n.t("jobseekers.job_application_mailer.job_listing_ended_early.heading",
                                                  job_title: vacancy.job_title, organisation_name: vacancy.organisation_name))
      expect(mail.body.encoded).to include(jobseekers_job_application_url(job_application))
    end

    it "triggers a `jobseeker_job_listing_ended_early` email event" do
      mail.deliver_now
      expect(:jobseeker_job_listing_ended_early).to have_been_enqueued_as_analytics_events
    end
  end
end
