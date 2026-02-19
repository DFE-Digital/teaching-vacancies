require "rails_helper"

RSpec.describe JobseekerMessage do
  let(:conversation) { build(:conversation) }
  let(:jobseeker) { build(:jobseeker) }

  describe "validations" do
    context "without a sender" do
      let(:message)  { build(:jobseeker_message, conversation: conversation, sender: nil) }

      it "has a strict validation" do
        expect { message.valid? }.to raise_error(ActiveModel::StrictValidationFailed, "Sender is mandatory")
      end
    end

    describe "#jobseeker_can_send_message" do
      before do
        allow(conversation).to receive(:job_application).and_return(job_application)
      end

      let(:job_application) { instance_double(JobApplication) }

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
