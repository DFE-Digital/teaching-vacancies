require "rails_helper"

RSpec.describe JobReference do
  describe "#mark_as_received" do
    let(:organisation) { create(:school) }
    let(:publisher) { create(:publisher) }
    let(:vacancy) { create(:vacancy, contact_email: contact_email, publisher: publisher) }
    let(:job_application) { create(:job_application, vacancy: vacancy) }
    let(:referee) { create(:referee, job_application: job_application) }
    let(:reference_request) { create(:reference_request, referee: referee) }
    let(:job_reference) { create(:job_reference, reference_request: reference_request) }

    context "when there is a registered publisher user" do
      let(:contact_email) { publisher.email }

      it "sends a notification to the registered user" do
        allow(Publishers::ReferenceReceivedNotifier).to receive(:with).with(record: job_reference).and_return(instance_double(Publishers::ReferenceReceivedNotifier, deliver: true))

        job_reference.mark_as_received

        expect(reference_request.reload.status).to eq("received")
        expect(reference_request.token).not_to be_nil
      end
    end

    context "when there is no registered publisher user" do
      let(:contact_email) { "unregistered@contoso.com" }

      it "sends an email via mailer" do
        allow(Publishers::CollectReferencesMailer).to receive(:reference_received).with(reference_request).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

        job_reference.mark_as_received

        expect(reference_request.reload.status).to eq("received")
        expect(reference_request.token).not_to be_nil
      end
    end
  end
end
