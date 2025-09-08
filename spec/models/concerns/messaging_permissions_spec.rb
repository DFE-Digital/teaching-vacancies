require "rails_helper"

RSpec.describe MessagingPermissions do
  let(:job_application) { create(:job_application, status: status) }

  describe "#can_jobseeker_initiate_message?" do
    context "when status allows jobseeker to initiate messages" do
      %w[interviewing unsuccessful_interview offered declined].each do |allowed_status|
        context "when status is #{allowed_status}" do
          let(:status) { allowed_status }

          it "returns true" do
            expect(job_application.can_jobseeker_initiate_message?).to be true
          end
        end
      end
    end

    context "when status does not allow jobseeker to initiate messages" do
      %w[submitted shortlisted unsuccessful withdrawn].each do |disallowed_status|
        context "when status is #{disallowed_status}" do
          let(:status) { disallowed_status }

          it "returns false" do
            expect(job_application.can_jobseeker_initiate_message?).to be false
          end
        end
      end
    end
  end

  describe "#can_jobseeker_reply_to_message?" do
    context "when status allows jobseeker to reply to messages" do
      %w[submitted shortlisted interviewing unsuccessful_interview offered declined].each do |allowed_status|
        context "when status is #{allowed_status}" do
          let(:status) { allowed_status }

          it "returns true" do
            expect(job_application.can_jobseeker_reply_to_message?).to be true
          end
        end
      end
    end

    context "when status does not allow jobseeker to reply to messages" do
      %w[unsuccessful withdrawn].each do |disallowed_status|
        context "when status is #{disallowed_status}" do
          let(:status) { disallowed_status }

          it "returns false" do
            expect(job_application.can_jobseeker_reply_to_message?).to be false
          end
        end
      end
    end
  end

  describe "#can_publisher_send_message?" do
    context "when status allows publisher to send messages" do
      %w[submitted shortlisted interviewing unsuccessful_interview offered declined unsuccessful].each do |allowed_status|
        context "when status is #{allowed_status}" do
          let(:status) { allowed_status }

          it "returns true" do
            expect(job_application.can_publisher_send_message?).to be true
          end
        end
      end
    end

    context "when status does not allow publisher to send messages" do
      context "when status is withdrawn" do
        let(:status) { "withdrawn" }

        it "returns false" do
          expect(job_application.can_publisher_send_message?).to be false
        end
      end
    end
  end
end