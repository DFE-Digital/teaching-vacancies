require "rails_helper"

RSpec.describe PublisherMessage do
  let(:job_application) { instance_double(JobApplication) }
  let(:conversation) { create(:conversation) }
  let(:publisher) { create(:publisher) }

  before do
    allow(conversation).to receive(:job_application).and_return(job_application)
  end

  describe "validations" do
    describe "#publisher_can_send_message" do
      context "when publisher can send message" do
        before do
          allow(job_application).to receive(:can_publisher_send_message?).and_return(true)
        end

        it "allows message creation" do
          message = build(:publisher_message, conversation: conversation, sender: publisher)

          expect(message).to be_valid
        end
      end

      context "when publisher cannot send message" do
        before do
          allow(job_application).to receive(:can_publisher_send_message?).and_return(false)
        end

        it "prevents message creation with validation error" do
          message = build(:publisher_message, conversation: conversation, sender: publisher)

          expect(message).not_to be_valid
          expect(message.errors[:base]).to include("Cannot send message for this job application status")
        end
      end
    end
  end
end
