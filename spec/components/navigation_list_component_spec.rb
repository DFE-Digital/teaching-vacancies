require "rails_helper"

RSpec.describe NavigationListComponent, type: :component do
  let(:title) { "A title" }
  let(:kwargs) { { title: } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when title is defined" do
    it "renders the title" do
      expect(page).to have_css("div", class: "navigation-list-component") do |navigation|
        expect(navigation).to have_css("h2", class: "govuk-heading-m", text: title)
      end
    end
  end

  context "when title is not defined" do
    let(:title) { nil }

    it "does not render the title" do
      expect(page).to have_css("div", class: "navigation-list-component") do |navigation|
        expect(navigation).not_to have_css("h2", class: "govuk-heading-m")
      end
    end
  end

  context "when anchors are defined" do
    subject! do
      render_inline(described_class.new(**kwargs)) do |navigation|
        navigation.anchor(text: "A link", href: "#to-this-place")
        navigation.anchor(text: "Another link", href: "#to-this-other-place")
      end
    end

    it "renders the anchors" do
      expect(page).to have_css("div", class: "navigation-list-component") do |navigation|
        expect(navigation).to have_css("div", class: "navigation-list-component__anchors") do |anchors|
          expect(anchors).to have_css("li", class: "navigation-list-component__anchor", text: "A link") do |anchor|
            expect(anchor).to have_css("a[href='#to-this-place']", class: "govuk-link")
          end

          expect(anchors).to have_css("li", class: "navigation-list-component__anchor", text: "Another link") do |anchor|
            expect(anchor).to have_css("a[href='#to-this-other-place']", class: "govuk-link")
          end
        end
      end
    end
  end

  context "when anchors are not defined" do
    it "does not render the anchors" do
      expect(page).to have_css("div", class: "navigation-list-component") do |navigation|
        expect(navigation).not_to have_css("div", class: "navigation-list-component__anchors")
      end
    end
  end
end
