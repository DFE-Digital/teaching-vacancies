require "rails_helper"

RSpec.describe ReviewComponent, type: :component do
  let(:id) { "test_review" }
  let(:title) { "Test title" }
  let(:text) { nil }
  let(:href) { nil }

  let(:kwargs) { { id: id, title: title, text: text, href: href } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when a content block is provided" do
    subject! { render_inline(described_class.new(**kwargs)) { tag.p("Some content here") } }

    it "renders the review component with a title and the content provided" do
      expect(page).to have_css("div", class: "review-component") do |review|
        expect(review).to have_css("h2", class: "review-component__heading review-component__section", id: "review-component-test_review-heading", text: title)
        expect(review).to have_css("div", class: "review-component__body") do |body|
          expect(body).to have_css("p", text: "Some content here")
        end
      end
    end
  end

  context "when text and href are nil" do
    it "renders the title without a link" do
      expect(page).to have_css("div", class: "review-component") do |review|
        expect(review).to have_css("h2", class: "review-component__heading review-component__section", id: "review-component-test_review-heading", text: title) do |heading|
          expect(heading).not_to have_css("a")
        end
      end
    end
  end

  context "when text and href are not nil" do
    let(:text) { "Do this action" }
    let(:href) { "/edit-link" }

    it "renders the title with the link" do
      expect(page).to have_css("div", class: "review-component") do |review|
        expect(review).to have_css("h2", class: "review-component__heading review-component__section", id: "review-component-test_review-heading", text: title) do |heading|
          expect(heading).to have_css("a[aria-label='Do this action Test review'][href='/edit-link']", class: %w[govuk-link review-component__section-button], text: text)
        end
      end
    end
  end
end
