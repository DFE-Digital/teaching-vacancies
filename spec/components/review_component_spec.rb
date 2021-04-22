require "rails_helper"

RSpec.describe ReviewComponent, type: :component do
  let(:id) { "test_id" }
  let(:kwargs) { { id: id } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when a heading slot is defined" do
    subject! { render_inline(described_class.new(**kwargs)) { |review| review.heading(title: title, text: text, href: href) } }

    let(:title) { "Special section" }
    let(:text) { nil }
    let(:href) { nil }

    context "when text and href are provided" do
      let(:text) { "Update" }
      let(:href) { "/test-link" }

      it "renders the edit link in the heading" do
        expect(page).to have_css("div", class: "review-component") do |review|
          expect(review).to have_css("h2", class: "govuk-heading-m", text: title)
          expect(review).to have_css("a", class: "govuk-link", text: text)
        end
      end
    end

    context "when text and href are not provided" do
      it "does not render the edit link in the heading" do
        expect(page).to have_css("div", class: "review-component") do |review|
          expect(review).to have_css("h2", class: "govuk-heading-m", text: title) do |heading|
            expect(heading).not_to have_css("a", class: "govuk-link")
          end
        end
      end
    end

    it "renders the heading with a title" do
      expect(page).to have_css("div", class: "review-component") do |review|
        expect(review).to have_css("h2", class: "govuk-heading-m", text: title)
      end
    end

    context "when a content block is provided" do
      subject! { render_inline(described_class.new(**kwargs)) { |review| review.heading(title: title) { tag.strong("A tag") } } }

      it "renders the heading with a title and the content provided" do
        expect(page).to have_css("div", class: "review-component") do |review|
          expect(review).to have_css("h2", class: "govuk-heading-m", text: title)
          expect(review).to have_css("strong", text: "A tag")
        end
      end
    end
  end

  context "when a heading slot is not defined" do
    it "does not render the heading" do
      expect(page).to have_css("div", class: "review-component") do |review|
        expect(review).not_to have_css("h2", class: "govuk-heading-m")
      end
    end
  end

  context "when a body slot is defined" do
    subject! { render_inline(described_class.new(**kwargs)) { |review| review.body { tag.p("A paragraph") } } }

    it "renders the body with the content provided" do
      expect(page).to have_css("div", class: "review-component") do |review|
        expect(review).to have_css("div", class: "review-component__body") do |body|
          expect(body).to have_css("p", text: "A paragraph")
        end
      end
    end
  end

  context "when a body slot is not defined" do
    it "does not render the body" do
      expect(page).to have_css("div", class: "review-component") do |review|
        expect(review).not_to have_css("div", class: "review-component__body")
      end
    end
  end
end
