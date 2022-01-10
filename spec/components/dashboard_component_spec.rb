require "rails_helper"

RSpec.describe DashboardComponent, type: :component do
  let(:heading) { "A heading" }
  let(:link) { nil }
  let(:background) { nil }
  let(:kwargs) { { background:, heading:, link: } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when heading is defined" do
    it "renders the heading" do
      expect(page).to have_css("div", class: "dashboard-component") do |dashboard|
        expect(dashboard).to have_css("h2", class: "govuk-heading-m", text: heading)
      end
    end
  end

  context "when background is true" do
    let(:background) { true }
    it "adds the background class" do
      expect(page).to have_css("div", class: "dashboard-component--background")
    end
  end

  context "when navigation items are defined" do
    subject! do
      render_inline(described_class.new(**kwargs)) do |dashboard|
        dashboard.navigation_item(item: "A dashboard item")
        dashboard.navigation_item(item: "Another dashboard item")
      end
    end

    it "renders the navigation items" do
      expect(page).to have_css("div", class: "dashboard-component") do |dashboard|
        expect(dashboard).to have_css("div", class: "dashboard-component-navigation__nav") do |items|
          expect(items).to have_css("li", class: "dashboard-component-navigation__item", text: "A dashboard item")
          expect(items).to have_css("li", class: "dashboard-component-navigation__item", text: "Another dashboard item")
        end
      end
    end
  end

  context "when link is not defined" do
    it "renders no link" do
      expect(page).to have_css("div", class: "dashboard-component") do |dashboard|
        expect(dashboard).not_to have_css("form", class: "dashboard-component__button")
      end
    end
  end

  context "when link is defined" do
    let(:link) { { text: "link text", url: "http://something" } }

    it "renders the link with name and url" do
      expect(page).to have_link(link[:text], href: link[:url])
    end
  end
end
