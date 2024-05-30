require "rails_helper"

RSpec.describe "Users can view help guides" do
  describe "content page" do
    context "when the post exists" do
      before { visit post_path(section: "get-help-hiring", post_name: "accepting-job-applications-on-teaching-vacancies") }

      it "renders the post with the correct title" do
        expect(page).to have_content("How to accept job applications")
      end
    end

    context "when the post does not exist" do
      before { visit post_path(section: "get-help-hiring", post_name: "non-existent-file") }

      it "renders page not found" do
        expect(page).to have_content(I18n.t("error_pages.not_found"))
      end
    end
  end

  describe "landing page" do
    before { visit posts_path(section: "get-help-hiring") }

    it "shows all links to content pages" do
      click_on("How to accept job applications")
      expect(current_path).to eq(post_path(section: "get-help-hiring", post_name: "accepting-job-applications-on-teaching-vacancies"))
    end
  end
end
