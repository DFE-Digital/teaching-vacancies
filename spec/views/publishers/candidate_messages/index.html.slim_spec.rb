require "rails_helper"

RSpec.describe "publishers/candidate_messages/index" do
  before do
    assign :tab, "inbox"
    assign :search_form, Publishers::CandidateMessagesSearchForm.new
    assign :sort, Publishers::CandidateMessagesSort.new
    assign :total_count, 1
    assign :pagy, Pagy.new(count: 0)
    assign :conversations, []
    assign :inbox_count, 1

    allow(view).to receive_messages(current_organisation: build_stubbed(:school))

    render
  end

  it "shows inbox tab with correct count" do
    expect(rendered).to have_content("Inbox (1)")
    expect(rendered).to have_content("Archive")
  end
end
