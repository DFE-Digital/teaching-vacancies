require "rails_helper"

RSpec.describe "publishers/candidate_messages/index" do
  before do
    assign :tab, "inbox"
    assign :search_form, Publishers::CandidateMessagesSearchForm.new
    assign :sort, Publishers::CandidateMessagesSort.new
    assign :total_count, 1
    assign :conversations, conversations
    assign :inbox_count, 1

    allow(view).to receive_messages(current_organisation: organisation)

    render
  end

  describe "reading messages" do
    let(:jobseeker) { build_stubbed(:jobseeker) }
    let(:organisation) { build_stubbed(:school) }
    let(:vacancy) { build_stubbed(:vacancy, :live, organisations: [organisation]) }
    let(:job_application) { build_stubbed(:job_application, :submitted, jobseeker: jobseeker, vacancy: vacancy, status: "interviewing") }
    let(:conversations) { build_stubbed_list(:conversation, 1, job_application: job_application, messages: messages) }

    context "with unread messages" do
      let(:messages) { build_stubbed_list(:jobseeker_message, 1, sender: jobseeker) }

      it "updates inbox total and marks message as read" do
        expect(rendered).to have_content("Archive")
        expect(rendered).to have_content("Inbox (1)")

        within("table tbody") do
          expect(rendered).to have_css("tr.conversation--unread")
        end
      end
    end

    context "without unread messages" do
      let(:messages) { build_stubbed_list(:jobseeker_message, 1, sender: jobseeker, read: true) }

      it "updates inbox total and marks message as read" do
        expect(rendered).to have_content("Inbox (0)")

        within("table tbody") do
          expect(rendered).to have_no_css("tr.conversation--unread")
        end
      end
    end
  end
end
