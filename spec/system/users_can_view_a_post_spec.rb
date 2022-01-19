require "rails_helper"

RSpec.describe "Users viewing a post" do
  let(:section) { "get-help-hiring" }
  let(:file_name) { "document" }
  let(:file_path) { Rails.root.join("app", "views", "content", section, "#{file_name}.md")}
  let(:document_content) { file_fixture("document.md").read }
  let(:file_exists?) { true }

  before do
    allow(File).to receive(:file?).with(file_path).and_return(file_exists?)
    allow(File).to receive(:read).with(file_path).and_return(document_content)
  end

  context "when the post exists" do
    scenario "the user can view the post" do
      visit post_path(section: "get-help-hiring", file_name: "document")
    end
  end

  # context "when the post does not exist" do

  #   scenario "" do
  #   end
  # end
end
