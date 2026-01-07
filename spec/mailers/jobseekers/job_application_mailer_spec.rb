require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe Jobseekers::JobApplicationMailer do
  let(:job_title) { Faker::Job.title }
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { build(:school) }
  let(:vacancy) { build(:vacancy, organisations: [organisation], job_title: job_title) }
  let(:contact_email) { vacancy.contact_email }

  let(:expected_data) do
    {
      notify_template: notify_template,
      email_identifier: anonymised_form_of(email),
      user_anonymised_jobseeker_id: anonymised_form_of(jobseeker.id),
      user_anonymised_publisher_id: nil,
    }
  end

  describe "#application_submitted" do
    let(:job_application) { build(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }
    let(:mail) { described_class.application_submitted(job_application) }

    it "sends a `jobseeker_application_submitted` email" do
      expect(mail.to).to eq([job_application.email_address])
      expect(mail.personalisation).to include(organisation_name: organisation.name, contact_email: contact_email)
    end

    it "triggers a `jobseeker_application_submitted` email event", :dfe_analytics do
      mail.deliver_now
      expect(:jobseeker_application_submitted).to have_been_enqueued_as_analytics_event(with_data: %i[uid notify_template]) # rubocop:disable RSpec/ExpectActual
    end
  end

  describe "#job_listing_ended_early" do
    let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy, email_address: "other.email@contoso.com") }
    let(:mail) { described_class.job_listing_ended_early(job_application, vacancy) }

    it "sends a `jobseeker_job_listing_ended_early` email to the jobseeker account's email address" do
      expect(mail.to).to eq([jobseeker.email])
      expect(mail.personalisation).to include(job_title: vacancy.job_title, organisation_name: vacancy.organisation_name, link: jobseekers_job_application_url(job_application))
    end

    it "triggers a `jobseeker_job_listing_ended_early` email event", :dfe_analytics do
      mail.deliver_now
      expect(:jobseeker_job_listing_ended_early).to have_been_enqueued_as_analytics_event(with_data: %i[uid notify_template]) # rubocop:disable RSpec/ExpectActual
    end
  end

  describe "#self_disclosure" do
    let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }
    let(:mail) { described_class.self_disclosure(job_application) }
    let(:self_disclosure_link) { jobseekers_job_application_self_disclosure_url(job_application, Wicked::FIRST_STEP) }

    it "sends a `declarations` email" do
      expect(mail.to).to eq([job_application.email_address])
      expect(mail.personalisation).to include({ link: self_disclosure_link })
    end
  end
end
