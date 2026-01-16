require "rails_helper"

RSpec.describe "publishers/candidate_messages/index" do
  include Pagy::Backend

  before do
    assign :tab, "inbox"
    assign :search_form, Publishers::CandidateMessagesSearchForm.new
    assign :sort, Publishers::CandidateMessagesSort.new

    assign :total_count, 16
    pagy, data = pagy_array(conversations, limit: 15)
    assign :conversations, data
    assign :pagy, pagy

    assign :inbox_count, 1

    allow(view).to receive_messages(current_organisation: build_stubbed(:school))

    render
  end

  let(:conversations) { build_stubbed_list(:conversation, 16, last_message_at: Time.current) }

  it "shows inbox tab with correct count" do
    expect(rendered).to have_content("Inbox (1)")
    expect(rendered).to have_content("Archive")
  end

  it "paginates all the conversations" do
    expect(rendered).to have_content("Showing 1 to 15 of 16 conversations")
  end

  describe "reading messages" do
    let(:jobseeker) { build_stubbed(:jobseeker) }
    let(:organisation) { build_stubbed(:school) }
    let(:vacancy) { build_stubbed(:vacancy, :live, organisations: [organisation]) }
    let(:job_application) { build_stubbed(:job_application, :submitted, jobseeker: jobseeker, vacancy: vacancy, status: "interviewing") }
    let(:conversations) { build_stubbed_list(:conversation, 1, last_message_at: Time.current, job_application: job_application, messages: messages) }

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

      it "marks message as read" do
        within("table tbody") do
          expect(rendered).to have_no_css("tr.conversation--unread")
        end
      end
    end
  end
end
