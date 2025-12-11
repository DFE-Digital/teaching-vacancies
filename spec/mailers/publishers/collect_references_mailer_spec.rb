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
      expect(mail.to).to eq(["contact@contoso.com"])
      expect(mail.personalisation[:candidate_name]).to eq(job_application.name)
      expect(mail.personalisation[:job_title]).to eq(vacancy.job_title)
      expect(mail.personalisation[:organisation_name]).to eq(vacancy.organisation_name)
    end
  end
end
