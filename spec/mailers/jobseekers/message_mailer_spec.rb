require "rails_helper"

RSpec.describe Jobseekers::MessageMailer do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy, status: status) }
  let(:conversation) { create(:conversation, job_application: job_application) }
  let(:message) { create(:publisher_message, conversation: conversation) }

  describe "#message_received" do
    subject(:mail) { described_class.message_received(message) }

    context "when job application is unsuccessful" do
      let(:status) { "unsuccessful" }

      it "has the correct subject" do
        expect(mail.subject).to eq("Your application for #{vacancy.job_title} at #{organisation.name} has been unsuccessful")
      end

      it "has the correct recipient" do
        expect(mail.to).to eq([jobseeker.email])
      end

      it "includes the unsuccessful application content" do
        expect(mail.body.encoded).to include("Your application for #{vacancy.job_title} at #{organisation.name} was unsuccessful")
      end

      it "includes the jobseeker's name" do
        expect(mail.body.encoded).to include("Dear #{job_application.first_name}")
      end

      it "includes sign in link" do
        expect(mail.body.encoded).to include("Sign in to your [Teaching Vacancies account]")
      end
    end

    context "when job application is not unsuccessful" do
      let(:status) { "submitted" }

      it "has the correct subject" do
        expect(mail.subject).to eq("You have a new message")
      end

      it "has the correct recipient" do
        expect(mail.to).to eq([jobseeker.email])
      end

      it "includes the default message content" do
        expect(mail.body.encoded).to include("You have received a message in your Teaching Vacancies account about the #{vacancy.job_title} role")
      end

      it "includes the jobseeker's name" do
        expect(mail.body.encoded).to include("Dear #{job_application.first_name}")
      end

      it "includes the cannot reply warning" do
        expect(mail.body.encoded).to include("You cannot reply to the message by responding to this email")
      end
    end
  end
end
