require "rails_helper"

RSpec.describe Publishers::CollectReferencesMailer do
  describe "#reference_received" do
    let(:organisation) { create(:school) }
    let(:vacancy) { create(:vacancy, contact_email: "contact@contoso.com", organisations: [organisation]) }
    let(:job_application) { create(:job_application, vacancy: vacancy) }
    let(:referee) { create(:referee, job_application: job_application) }
    let(:reference_request) { create(:reference_request, referee: referee) }
    let(:mail) { described_class.reference_received(reference_request) }

    it "includes all expected information" do
      expected_subject = I18n.t(
        "publishers.collect_references_mailer.reference_received.subject",
        organisation_name: organisation.name,
        candidate_name: job_application.name,
        job_title: vacancy.job_title,
      )
      expect(mail.to).to eq(["contact@contoso.com"])
      expect(mail.subject).to eq(expected_subject)
      expect(mail.body.encoded).to include(job_application.name)
      expect(mail.body.encoded).to include(vacancy.job_title)
    end
  end
end
