require "rails_helper"

RSpec.describe Shared::ReviewComponent, type: :component do
  let(:id) { "test_review" }
  let(:title) { "Test title" }
  let(:edit_link) { "/edit_test_review" }
  let(:summary) { "Test summary" }
  let(:kwargs) { { id: id, title: title, edit_link: edit_link, summary: summary } }

  subject! { render_inline(described_class.new(**kwargs)) }

  context "when an edit_link is supplied" do
    it "contains a div element with the correct id, title, edit link, summary and aria-label" do
      expect(page).to have_css("div", class: %w[review-component]) do |review|
        expect(review).to have_css("h2", class: %w[govuk-heading-m review-component__heading review-component__section], id: "test_review_heading", text: title) do |heading|
          expect(heading).to have_css("a[aria-label='Change Test review'][href='/edit_test_review']", class: %w[govuk-link review-component__section-button], text: I18n.t("buttons.change"))
        end
        expect(review).to have_css(".review-component__body", text: summary)
      end
    end
  end

  context "when an edit_link is not supplied" do
    let(:edit_link) { nil }

    it "contains a div element with the correct id, title, summary and aria-label" do
      expect(page).to have_css("div", class: %w[review-component]) do |review|
        expect(review).to have_css("h2", class: %w[govuk-heading-m review-component__heading review-component__section], id: "test_review_heading", text: title)
        expect(review).to have_css(".review-component__body", text: summary)
      end
    end
  end

  context "when a summary is supplied" do
    it "contains a div element with the correct id, title, edit link, summary and aria-label" do
      expect(page).to have_css("div", class: %w[review-component]) do |review|
        expect(review).to have_css("h2", class: %w[govuk-heading-m review-component__heading review-component__section], id: "test_review_heading", text: title) do |heading|
          expect(heading).to have_css("a[aria-label='Change Test review'][href='/edit_test_review']", class: %w[govuk-link review-component__section-button], text: I18n.t("buttons.change"))
        end
        expect(review).to have_css(".review-component__body", text: summary)
      end
    end
  end

  context "when a block is supplied" do
    subject! { render_inline(described_class.new(**kwargs.except(:summary))) { summary } }

    it "contains a div element with the correct id, title, edit link, summary and aria-label" do
      expect(page).to have_css("div", class: %w[review-component]) do |review|
        expect(review).to have_css("h2", class: %w[govuk-heading-m review-component__heading review-component__section], id: "test_review_heading", text: title) do |heading|
          expect(heading).to have_css("a[aria-label='Change Test review'][href='/edit_test_review']", class: %w[govuk-link review-component__section-button], text: I18n.t("buttons.change"))
        end
        expect(review).to have_css(".review-component__body", text: summary)
      end
    end
  end

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"
end
