require "rails_helper"

RSpec.describe "Publishers can preview an organisation or school profile" do
  let(:publisher) { create(:publisher, organisations: [organisation]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit publisher_root_path
  end

  after { logout }

  context "when the publisher is signed in as a school" do
    let(:organisation) { create(:school) }

    before do
      click_link I18n.t("nav.organisation_profile", name: organisation.name)
      click_link I18n.t("publishers.organisations.show.preview_link_text", organisation_type: "school")
      # wait for page load
      find(".map-component")
    end

    it "passes a11y", :a11y do
      expect(page).to be_axe_clean
    end

    it "displays a profile summary" do
      has_profile_summary?(page, organisation)
    end
  end
end
