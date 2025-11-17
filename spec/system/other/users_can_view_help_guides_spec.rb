require "rails_helper"

RSpec.describe "Users can view help guides" do
  describe "content page" do
    context "when the post exists" do
      before { visit post_path(section: "get-help-hiring", subcategory: "how-to-create-job-listings-and-accept-applications", post_name: "accepting-job-applications-on-teaching-vacancies") }

      it "renders the post with the correct title" do
        expect(page).to have_content("Using the Teaching Vacancies application form")
      end

      it "passes a11y", :a11y do
        expect(page).to be_axe_clean
      end
    end

    context "when the post does not exist" do
      before { visit post_path(section: "get-help-hiring", subcategory: "get-help-applying-for-your-teaching-role", post_name: "non-existent-file") }

      it "renders page not found" do
        expect(page).to have_content(I18n.t("error_pages.not_found"))
      end
    end
  end

  describe "landing page" do
    before { visit posts_path(section: "get-help-hiring") }

    it "shows all links to content pages" do
      click_on("How to create job listings and accept applications")
      click_on("Using the Teaching Vacancies application form")
      expect(current_path).to eq(post_path(section: "get-help-hiring", subcategory: "how-to-create-job-listings-and-accept-applications", post_name: "accepting-job-applications-on-teaching-vacancies"))
    end

    it "shows link to communicating with jobseekers page" do
      click_on("How to create job listings and accept applications")
      click_on("Communicating with jobseekers")
      expect(current_path).to eq(post_path(section: "get-help-hiring", subcategory: "how-to-create-job-listings-and-accept-applications", post_name: "communicating-with-jobseekers"))
    end
  end
end
