require "rails_helper"

RSpec.describe PublisherMessage do
  let(:conversation) { create(:conversation, job_application: job_application) }
  let(:publisher) { create(:publisher) }

  describe "validations" do
    describe "#publisher_can_send_message" do
      context "when publisher can send message" do
        let(:job_application) { create(:job_application, :status_interviewing) }
        let(:message) { build(:publisher_message, conversation: conversation, sender: publisher) }

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

      context "when publisher cannot send message" do
        let(:job_application) { create(:job_application, :status_withdrawn) }
        let(:message) { build(:publisher_message, conversation: conversation, sender: publisher) }

        it "prevents message creation with validation error" do
          expect(message).not_to be_valid
          expect(message.errors[:base]).to include("Cannot send message for this job application status")
        end
      end
    end
  end
end
