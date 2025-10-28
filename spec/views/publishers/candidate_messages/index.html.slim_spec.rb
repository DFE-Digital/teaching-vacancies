require "rails_helper"

RSpec.describe "publishers/candidate_messages/index" do
  before do
    assign :tab, "inbox"
    assign :search_form, Publishers::CandidateMessagesSearchForm.new
    assign :sort, Publishers::CandidateMessagesSort.new

    assign :total_count, 16
    assign :conversations, conversations.first(15)
    assign :pagy, Pagy.new(count: 15, page: 1, items: 15)

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
end
