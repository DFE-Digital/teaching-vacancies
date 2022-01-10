require "rails_helper"

RSpec.describe DetailComponent, type: :component do
  let(:title) { "Detail title" }
  let(:kwargs) { { title: } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  it "renders the detail with a title" do
    expect(page).to have_css("div", class: "detail-component") do |detail|
      expect(detail).to have_css("div", class: "detail-component__title") do |detail_title|
        expect(detail_title).to have_css(".govuk-heading-s", text: title)
      end
    end
  end

  context "when a title isn't defined" do
    let(:title) { nil }

    it "renders the detail without a title" do
      expect(page).to have_css("div", class: "detail-component") do |detail|
        expect(detail).not_to have_css("div", class: "detail-component__title")
      end
    end
  end

  context "when body and action slots are not defined" do
    it "renders the detail without body" do
      expect(page).to have_css("div", class: "detail-component") do |detail|
        expect(detail).not_to have_css("div", class: "detail-component__body")
      end
    end

    it "renders the detail without actions" do
      expect(page).to have_css("div", class: "detail-component") do |detail|
        expect(detail).not_to have_css("div", class: "detail-component__actions")
      end
    end
  end

  context "when body and actions slots are defined" do
    subject! do
      render_inline(described_class.new) do |detail|
        detail.body { tag.p "Hello!" }
        detail.actions { tag.a "Click this", href: "/test-url" }
      end
    end

    it "renders the detail with body" do
      expect(page).to have_css("div", class: "detail-component") do |detail|
        expect(detail).to have_css("div", class: "detail-component__body") do |body|
          expect(body).to have_css("p", text: "Hello!")
        end
      end
    end

    it "renders the detail with actions" do
      expect(page).to have_css("div", class: "detail-component") do |detail|
        expect(detail).to have_css("div", class: "detail-component__actions") do |actions|
          expect(actions).to have_css("a[href='/test-url']", text: "Click this")
        end
      end
    end
  end
end
