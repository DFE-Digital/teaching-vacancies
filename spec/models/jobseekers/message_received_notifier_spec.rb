require "rails_helper"

RSpec.describe Jobseekers::MessageReceivedNotifier do
  let(:jobseeker) { create(:jobseeker, given_name: "John") }
  let(:organisation) { create(:organisation, name: "Test School") }
  let(:vacancy) { create(:vacancy, job_title: "Math Teacher", organisations: [organisation]) }
  let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy, status: status) }
  let(:conversation) { create(:conversation, job_application: job_application) }
  let(:message) { create(:publisher_message, conversation: conversation) }

  describe "#recipients" do
    let(:status) { "submitted" }

    it "returns the jobseeker from the job application" do
      notification = described_class.with(message: message)
      
      expect(notification.recipients).to eq([jobseeker])
    end
  end

  describe "#message_text" do
    subject { described_class.with(message: message).new.message_text }

    context "when job application is unsuccessful" do
      let(:status) { "unsuccessful" }

      it "returns the unsuccessful message" do
        expect(subject).to include("Your application for Math Teacher at Test School was unsuccessful")
      end
    end

    context "when job application is not unsuccessful" do
      let(:status) { "submitted" }

      it "returns the default message" do
        expect(subject).to include("You have received a message about the Math Teacher role")
      end
    end
  end

  describe "email delivery" do
    let(:status) { "submitted" }
    let(:mail_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(Jobseekers::MessageMailer).to receive(:message_received).and_return(mail_delivery)
      allow(mail_delivery).to receive(:deliver_now)
    end

    it "sends an email via the MessageMailer" do
      described_class.with(message: message).deliver(jobseeker)

      expect(Jobseekers::MessageMailer).to have_received(:message_received).with(message: message)
      expect(mail_delivery).to have_received(:deliver_now)
    end
  end

  describe "#unsuccessful_application?" do
    subject { described_class.with(message: message).new.send(:unsuccessful_application?) }

    context "when job application status is unsuccessful" do
      let(:status) { "unsuccessful" }

      it { is_expected.to be true }
    end

    context "when job application status is not unsuccessful" do
      let(:status) { "submitted" }

      it { is_expected.to be false }
    end
  end
end