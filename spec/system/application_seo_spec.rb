require "rails_helper"
RSpec.describe "Application meta tags" do
  context "when visiting the service start page" do
    scenario "meta tags are present" do
      visit root_path
      expect(page.find('meta[name="description"]', visible: false)).to be_present
    end
  end
end
