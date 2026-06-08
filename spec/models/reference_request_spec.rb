# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReferenceRequest do
  describe "#handle_unsafe_attachment" do
    let(:organisation) { create(:school) }
    let!(:publisher) { create(:publisher, organisations: [organisation], email: "contact@example.com") }
    let(:vacancy) { create(:vacancy, publisher: publisher, contact_email: "contact@example.com", organisations: [organisation]) }
    let(:job_application) { create(:job_application, vacancy: vacancy) }
    let(:reference_request) { create(:reference_request, status: :received_off_service, referee: create(:referee, job_application: job_application)) }
    let(:attachment) { instance_double(ActiveStorage::Attachment) }

    it "destroys the referee" do
      referee = reference_request.referee
      reference_request.handle_unsafe_attachment(attachment)
      expect { referee.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when a publisher with the vacancy contact email exists" do
      it "delivers the reference document malware scan notifier" do
        notifier = instance_double(Publishers::ReferenceDocumentMalwareScanNotifier, deliver: true)
        allow(Publishers::ReferenceDocumentMalwareScanNotifier).to receive(:with).and_return(notifier)

        reference_request.handle_unsafe_attachment(attachment)

        expect(Publishers::ReferenceDocumentMalwareScanNotifier).to have_received(:with).with(job_application: job_application)
        expect(notifier).to have_received(:deliver).with(no_args)
      end

      it "sends an in-app notification to the publisher" do
        reference_request.handle_unsafe_attachment(attachment)
        expect(publisher.notifications.last.message).to include(job_application.name)
      end
    end

    context "when no publisher with the vacancy contact email exists" do
      let(:vacancy) { create(:vacancy, publisher: publisher, contact_email: "unregistered@example.com", organisations: [organisation]) }

      it "sends an email directly to the vacancy contact email" do
        expect { reference_request.handle_unsafe_attachment(attachment) }
          .to have_enqueued_mail(Publishers::ReferenceDocumentMalwareScanMailer, :reference_removed)
      end
    end
  end
end
