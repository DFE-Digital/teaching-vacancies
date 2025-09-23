require "rails_helper"
require "pdf/inspector"

RSpec.describe MessagesPdfGenerator do
  let(:publisher) { build_stubbed(:publisher, given_name: "John", family_name: "Smith") }
  let(:vacancy) { build_stubbed(:vacancy, :at_one_school, publisher: publisher) }
  let(:job_application) { build_stubbed(:job_application, :status_submitted, vacancy: vacancy) }
  let(:conversation) { build_stubbed(:conversation, job_application: job_application) }
  let(:publisher_message) { build_stubbed(:publisher_message, conversation: conversation, sender: publisher) }
  let(:jobseeker_message) { build_stubbed(:jobseeker_message, conversation: conversation) }
  let(:messages) { [publisher_message, jobseeker_message] }
  let(:generator) { described_class.new(job_application, messages) }

  describe "#generate" do
    subject(:document) { generator.generate }

    let(:pdf) { PDF::Inspector::Text.analyze(document.render).strings }

    it { is_expected.to be_a(Prawn::Document) }

    it "includes page header and footer information" do
      expect(pdf).to include("Messages")
      expect(pdf).to include("Messages for #{vacancy.job_title}")
      expect(pdf).to include("#{job_application.first_name} #{job_application.last_name}")
      expect(pdf).to include("1 of 1")
      expect(pdf).to include("#{job_application.first_name} #{job_application.last_name} | #{vacancy.organisation_name}")
    end

    context "when there are no messages" do
      let(:messages) { [] }

      it "displays no messages text" do
        expect(pdf).to include("No messages yet.")
      end
    end

    context "when there are messages" do
      it "includes message content, sender names and timestamps in table format" do
        expect(pdf).to include(publisher_message.content.to_plain_text)
        expect(pdf).to include(jobseeker_message.content.to_plain_text)

        expect(pdf).to include("John Smith - #{vacancy.organisation_name} (Hiring staff)")
        expect(pdf).to include("#{job_application.first_name} #{job_application.last_name} (Candidate)")

        publisher_timestamp = publisher_message.created_at.strftime("%d %B %Y at %I:%M %p")
        jobseeker_timestamp = jobseeker_message.created_at.strftime("%d %B %Y at %I:%M %p")
        expect(pdf).to include(publisher_timestamp)
        expect(pdf).to include(jobseeker_timestamp)

        # Check table format labels
        expect(pdf).to include("From:")
        expect(pdf).to include("Date:")
        expect(pdf).to include("Message:")
      end
    end

    context "when messages contain rich text content" do
      let(:publisher_message) { build_stubbed(:publisher_message, :with_rich_content, conversation: conversation, sender: publisher) }

      it "strips HTML tags from content" do
        expect(pdf).to include("This message contains rich text formatting.")
        expect(pdf).not_to include("<p>")
        expect(pdf).not_to include("<strong>")
        expect(pdf).not_to include("</p>")
        expect(pdf).not_to include("</strong>")
      end
    end
  end
end
