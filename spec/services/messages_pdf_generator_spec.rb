require "rails_helper"
require "pdf/inspector"

RSpec.describe MessagesPdfGenerator do
  let(:publisher) { build_stubbed(:publisher, given_name: "John", family_name: "Smith") }
  let(:vacancy) { build_stubbed(:vacancy, :at_one_school, publisher: publisher) }
  let(:job_application) { build_stubbed(:job_application, :status_submitted, vacancy: vacancy, conversations: [conversation]) }
  let(:generator) { described_class.new(job_application, conversation.messages) }

  describe "#generate" do
    subject(:document) { generator.generate }

    let(:pdf) do
      PDF::Inspector::Text.analyze(document.render).strings
    end
    let(:pdf_text) { pdf.join(" ") }

    context "when there are no messages" do
      let(:conversation) { build_stubbed(:conversation) }

      # One example per document: rendering the PDF is the slow part.
      it "renders an empty conversation", :aggregate_failures do
        expect(document).to be_a(Prawn::Document)
        expect(pdf_text).to include("No messages yet.")
        expect(pdf_text).to include("Messages for #{vacancy.job_title}")
        expect(pdf_text).to include("#{job_application.first_name} #{job_application.last_name} | #{vacancy.organisation_name}")
        expect(pdf_text).to include("1 of 1")
      end
    end

    context "when there are messages" do
      let(:conversation) { build_stubbed(:conversation, messages: [publisher_message, jobseeker_message]) }
      let(:publisher_message) { build_stubbed(:publisher_message, sender: publisher, content: "publisher message") }
      let(:jobseeker_message) { build_stubbed(:jobseeker_message, content: "jobseeker message") }

      it "renders both messages with their senders and timestamps", :aggregate_failures do
        expect(pdf_text).to include(publisher_message.content.to_plain_text)
        expect(pdf_text).to include(jobseeker_message.content.to_plain_text)

        expect(pdf_text).to include("John Smith - #{vacancy.organisation_name} (Hiring staff)")
        expect(pdf_text).to include("#{job_application.first_name} #{job_application.last_name} (Candidate)")

        expect(pdf_text).to include(publisher_message.created_at.strftime("%d %B %Y at %I:%M %p"))
        expect(pdf_text).to include(jobseeker_message.created_at.strftime("%d %B %Y at %I:%M %p"))

        expect(pdf_text).to include("From:")
        expect(pdf_text).to include("Date:")
        expect(pdf_text).to include("Message:")
      end
    end
  end
end
