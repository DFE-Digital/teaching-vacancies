require "rails_helper"

RSpec.describe EmptySectionComponent, type: :component do
  let(:title) { "A lovely title" }
  let(:kwargs) { { title: } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  it "renders the empty section with a title" do
    expect(page).to have_css("div", class: "empty-section-component") do |section|
      expect(section).to have_css("h3", class: "govuk-heading-m", text: title)
    end
  end

  context "when no title is specified" do
    let(:title) { nil }

    it "renders the empty section without a title" do
      expect(page).to have_css("div", class: "empty-section-component") do |section|
        expect(section).not_to have_css("h3", class: "govuk-heading-m")
      end
    end
  end

  context "when a content block is provided" do
    subject! do
      render_inline(described_class.new(**kwargs)) do
        tag.p "Some content here", class: "govuk-body"
      end
    end

    it "renders the empty section with a title and the content provided" do
      expect(page).to have_css("div", class: "empty-section-component") do |section|
        expect(section).to have_css("h3", class: "govuk-heading-m", text: title)
        expect(section).to have_css("p", class: "govuk-body", text: "Some content here")
      end
    end
  end
end
