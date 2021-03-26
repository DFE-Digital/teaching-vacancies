require "rails_helper"

RSpec.describe BannerComponent, type: :component do
  let(:kwargs) { {} }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when content is provided" do
    subject! { render_inline(described_class.new) { tag.h2 "Hello" } }

    it "renders the banner with the content" do
      expect(page).to have_css("div", class: "banner-component") do |banner|
        expect(banner).to have_css(".govuk-width-container > .govuk-grid-row > .govuk-grid-column-full") do |content|
          expect(content).to have_css("h2", text: "Hello")
        end
      end
    end
  end
end
