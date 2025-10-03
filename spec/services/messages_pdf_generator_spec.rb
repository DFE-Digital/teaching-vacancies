require "rails_helper"
require "pdf/inspector"

RSpec.describe MessagesPdfGenerator do
  let(:publisher) { build_stubbed(:publisher, given_name: "John", family_name: "Smith") }
  let!(:vacancy) { build_stubbed(:vacancy, :at_one_school, publisher: publisher, job_applications: [job_application]) }
  let(:job_application) { build_stubbed(:job_application, :status_submitted, conversations: [conversation]) }
  let(:generator) { described_class.new(job_application, conversation.messages) }

  describe "#generate" do
    subject(:document) { generator.generate }

    let(:pdf) do
      PDF::Inspector::Text.analyze(document.render).strings
    end

    context "when there are no messages" do
      let(:conversation) { build_stubbed(:conversation) }

      it { is_expected.to be_a(Prawn::Document) }

      it "displays no messages text" do
        expect(pdf).to include("No messages yet.")
      end

      it "includes page header and footer information" do
        expect(pdf).to include("Messages")
        expect(pdf).to include("Messages for #{vacancy.job_title}")
        expect(pdf).to include("#{job_application.first_name} #{job_application.last_name}")
        expect(pdf).to include("1 of 1")
        expect(pdf).to include("#{job_application.first_name} #{job_application.last_name} | #{vacancy.organisation_name}")
      end
    end

    context "when there are messages" do
      let(:conversation) { build_stubbed(:conversation, messages: [publisher_message, jobseeker_message]) }
      let(:publisher_message) { build_stubbed(:publisher_message, sender: publisher) }
      let(:jobseeker_message) { build_stubbed(:jobseeker_message) }

      it "includes message content, sender names and timestamps in table format" do
        expect(pdf).to include(publisher_message.content.to_plain_text)
        expect(pdf).to include(jobseeker_message.content.to_plain_text)

        expect(pdf).to include("John Smith - #{vacancy.organisation_name} (Hiring staff)")
        expect(pdf).to include("#{job_application.first_name} #{job_application.last_name} (Candidate)")

        publisher_timestamp = publisher_message.created_at.strftime("%d %B %Y at %I:%M %p")
        jobseeker_timestamp = jobseeker_message.created_at.strftime("%d %B %Y at %I:%M %p")
        expect(pdf).to include(publisher_timestamp)
        expect(pdf).to include(jobseeker_timestamp)

        expect(pdf).to include("From:")
        expect(pdf).to include("Date:")
        expect(pdf).to include("Message:")
      end
    end
  end
end
