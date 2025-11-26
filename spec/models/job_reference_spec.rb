require "rails_helper"

RSpec.describe JobReference do
  describe "#mark_as_received" do
    let(:organisation) { create(:trust) }
    let(:publisher) { create(:publisher) }
    let(:vacancy) { create(:vacancy, contact_email: contact_email, publisher: publisher, organisations: [organisation]) }
    let(:job_application) { create(:job_application, vacancy: vacancy) }
    let(:referee) { create(:referee, job_application: job_application) }
    let(:reference_request) { create(:reference_request, referee: referee) }
    let(:job_reference) { create(:job_reference, reference_request: reference_request) }

    context "when there is a registered publisher user" do
      let(:contact_email) { publisher.email }

      it "sends a notification to the registered user" do
        notifier = instance_double(Publishers::ReferenceReceivedNotifier, deliver: true)

        allow(Publishers::ReferenceReceivedNotifier).to receive(:with).and_return(notifier)
        expect(Publishers::ReferenceReceivedNotifier).to receive(:with).with(record: job_reference)

        job_reference.mark_as_received

        expect(reference_request.reload.status).to eq("received")
        expect(reference_request.token).not_to be_nil
      end
    end

    context "when there is no registered publisher user" do
      let(:contact_email) { "unregistered@contoso.com" }

      it "sends an email via mailer" do
        mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(Publishers::CollectReferencesMailer).to receive(:reference_received).and_return(mailer)
        expect(Publishers::CollectReferencesMailer).to receive(:reference_received).with(reference_request)

        job_reference.mark_as_received

        expect(reference_request.reload.status).to eq("received")
        expect(reference_request.token).not_to be_nil
      end
    end

    context "when a publisher with matching contact_email is in another of the vacancy's organisations" do
      let(:other_org) { create(:school) }
      let!(:other_publisher) { create(:publisher, organisations: [other_org]) }
      let(:contact_email) { other_publisher.email }

      before do
        vacancy.organisations << other_org
      end

      it "sends a notification to the publisher in the other organisation" do
        notifier = instance_double(Publishers::ReferenceReceivedNotifier, deliver: true)

        allow(Publishers::ReferenceReceivedNotifier).to receive(:with).and_return(notifier)
        expect(Publishers::ReferenceReceivedNotifier).to receive(:with).with(record: job_reference)

        job_reference.mark_as_received

        expect(reference_request.reload.status).to eq("received")
        expect(reference_request.token).not_to be_nil
      end
    end
  end
end
