require "rails_helper"

RSpec.describe Jobseekers::MessageReceivedNotifier do
  let(:organisation) { create(:school, name: "Test School") }
  let(:vacancy) { create(:vacancy, job_title: "Math Teacher", organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy, status: status) }
  let(:conversation) { create(:conversation, job_application: job_application) }
  let(:message) { create(:publisher_message, conversation: conversation) }

  describe "#message_text" do
    context "when job application is unsuccessful" do
      let(:status) { "unsuccessful" }

      before do
        described_class.with(record: message).deliver(jobseeker)
      end

      it "returns the unsuccessful message" do
        expect(jobseeker.notifications.last.message_text).to include("Your application for Math Teacher at Test School was unsuccessful")
      end
    end

    context "when job application is not unsuccessful" do
      let(:status) { "submitted" }

      before do
        described_class.with(record: message).deliver(jobseeker)
      end

      it "returns the default message" do
        expect(jobseeker.notifications.last.message_text).to include("You have received a message about the Math Teacher role")
      end
    end
  end

  describe "#timestamp" do
    let(:status) { "submitted" }

    context "when the notification is delivered today" do
      before do
        described_class.with(record: message).deliver(jobseeker)
      end

      it "returns the correct timestamp" do
        expect(jobseeker.notifications.last.timestamp).to match(/Today at/)
      end
    end
  end

  describe "#message" do
    let(:status) { "submitted" }

    it "returns the record" do
      notifier = described_class.with(record: message)
      expect(notifier.message).to eq(message)
    end
  end
end
