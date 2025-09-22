require "rails_helper"

RSpec.describe Publishers::MessageReceivedNotifier do
  let(:organisation) { create(:school, name: "Test School") }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:vacancy) { create(:vacancy, job_title: "Math Teacher", organisations: [organisation]) }
  let(:job_application) { create(:job_application, vacancy: vacancy, first_name: "John", last_name: "Doe", status: "interviewing") }
  let(:conversation) { create(:conversation, job_application: job_application) }
  let(:message) { create(:jobseeker_message, conversation: conversation) }

  describe "#message" do
    before do
      described_class.with(record: message).deliver(publisher)
    end

    it "returns the message with job title and candidate name" do
      notification_message = publisher.notifications.last.message
      expect(notification_message).to match(/John Doe has sent you.*a message.*about the Math Teacher role/)
    end
  end

  describe "#timestamp" do
    context "when the notification is delivered today" do
      before do
        described_class.with(record: message).deliver(publisher)
      end

      it "returns the correct timestamp" do
        expect(publisher.notifications.last.timestamp).to match(/Today at/)
      end
    end
  end
end
