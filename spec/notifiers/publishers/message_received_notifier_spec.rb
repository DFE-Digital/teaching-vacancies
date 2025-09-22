require "rails_helper"

RSpec.describe Publishers::MessageReceivedNotifier do
  let(:organisation) { create(:school, name: "Test School") }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:vacancy) { create(:vacancy, job_title: "Math Teacher", organisations: [organisation], publisher: publisher) }
  let(:job_application) { create(:job_application, vacancy: vacancy, first_name: "John", last_name: "Doe", status: "interviewing") }
  let(:conversation) { create(:conversation, job_application: job_application) }
  
  around do |example|
    # disabling the callback so that we don't have the Publishers::MessageReceivedNotifier called automatically upon message creation
    # this way it is only called when we explicitly call it in the tests.
    JobseekerMessage.skip_callback(:create, :after, :notify_publisher)
    example.run
    JobseekerMessage.set_callback(:create, :after, :notify_publisher)
  end
  
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

  describe "recipients" do
    it "delivers to the job application's publisher" do
      expect { described_class.with(record: message).deliver }.to change { publisher.notifications.count }.from(0).to(1)
    end
  end

  describe "#timestamp" do
    context "when the notification is delivered today" do
      before do
        described_class.with(record: message).deliver
      end

      it "returns the correct timestamp" do
        expect(publisher.notifications.last.timestamp).to match(/Today at/)
      end
    end
  end
end
