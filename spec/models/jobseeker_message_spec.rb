require "rails_helper"

RSpec.describe JobseekerMessage do
  let(:conversation) { build(:conversation, job_application: job_application) }
  let(:jobseeker) { build(:jobseeker) }

  describe "validations" do
    context "without a sender" do
      let(:job_application) { build(:job_application) }
      let(:message) { build(:jobseeker_message, conversation: conversation, sender: nil) }

      it "has a strict validation" do
        expect { message.valid? }.to raise_error(ActiveModel::StrictValidationFailed, "Sender is mandatory")
      end
    end

    describe "#jobseeker_can_send_message" do
      before do
        allow(conversation).to receive(:job_application).and_return(job_application)
      end

      let(:job_application) { instance_double(JobApplication) }

      context "when jobseeker can initiate a message" do
        let(:job_application) { create(:job_application, :status_interviewing) }
        let(:message) { build(:jobseeker_message, conversation: conversation, sender: jobseeker) }

        it "allows message creation" do
          expect(message).to be_valid
        end

        context "when application is subsequently withdrawn" do
          before do
            message.save!
            job_application.assign_attributes(status: "withdrawn")
            job_application.save!(validate: false)
          end

          it "stays valid" do
            expect(message).to be_valid
          end
        end
      end

      context "when jobseeker cannot initiate a message" do
        let(:job_application) { create(:job_application, :status_withdrawn) }
        let(:message) { build(:jobseeker_message, conversation: conversation, sender: jobseeker) }

        it "prevents message creation with validation error" do
          expect(message).not_to be_valid
          expect(message.errors[:base]).to include("Cannot send message for this job application status")
        end
      end
    end
  end
end
