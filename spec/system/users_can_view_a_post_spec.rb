require "rails_helper"

RSpec.describe "Users viewing a post" do
  context "when the post exists" do
    before { visit post_path(section: "get-help-hiring", file_name: "sample") }

    it "renders the post with the correct title" do
      expect(page).to have_content("Sample title")
    end
  end

  context "when the post does not exist" do
    before { visit post_path(section: "get-help-hiring", file_name: "non-existent-file") }

    it "redirects to not found" do
      expect(current_path).to eq(not_found_path)
    end
  end
end
