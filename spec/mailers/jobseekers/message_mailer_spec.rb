require "rails_helper"

RSpec.describe Jobseekers::MessageMailer do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }
  let(:conversation) { create(:conversation, job_application: job_application) }
  let(:message) { create(:publisher_message, conversation: conversation) }

  describe "#rejection_message" do
    subject(:mail) { described_class.rejection_message(message) }

    it "has the correct recipient" do
      expect(mail.to).to eq([jobseeker.email])
    end

    it "includes the unsuccessful application content" do
      expect(mail.personalisation).to include({ job_title: vacancy.job_title, organisation_name: organisation.name })
    end

    it "includes the jobseeker's name" do
      expect(mail.personalisation).to include(first_name: job_application.first_name)
    end
  end

  describe "#message_received" do
    subject(:mail) { described_class.message_received(message) }

    it "has the correct recipient" do
      expect(mail.to).to eq([jobseeker.email])
    end

    it "includes the default message content" do
      expect(mail.personalisation).to include({ job_title: vacancy.job_title, organisation_name: organisation.name })
    end

    it "includes the jobseeker's name" do
      expect(mail.personalisation).to include(first_name: job_application.first_name)
    end
  end
end
