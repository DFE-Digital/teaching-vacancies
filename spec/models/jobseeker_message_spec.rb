require "rails_helper"

RSpec.describe JobseekerMessage do
  let(:job_application) { instance_double(JobApplication) }
  let(:conversation) { create(:conversation) }
  let(:jobseeker) { create(:jobseeker) }

  before do
    allow(conversation).to receive(:job_application).and_return(job_application)
  end

  describe "validations" do
    describe "#jobseeker_can_send_message" do
      context "when jobseeker can send message" do
        before do
          allow(job_application).to receive(:can_jobseeker_send_message?).and_return(true)
        end

        it "allows message creation" do
          message = build(:jobseeker_message, conversation: conversation, sender: jobseeker)

          expect(message).to be_valid
        end
      end

      context "when jobseeker cannot send message" do
        before do
          allow(job_application).to receive(:can_jobseeker_send_message?).and_return(false)
        end

        it "prevents message creation with validation error" do
          message = build(:jobseeker_message, conversation: conversation, sender: jobseeker)

          expect(message).not_to be_valid
          expect(message.errors[:base]).to include("Cannot send message for this job application status")
        end
      end
    end
  end
end
