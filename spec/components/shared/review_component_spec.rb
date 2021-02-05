require "rails_helper"

RSpec.describe Shared::ReviewComponent, type: :component do
  let(:title) { "Review section title" }
  let(:edit_link) { "http://edit.com" }

  describe "renders correctly" do
    let!(:inline_component) { render_inline(described_class.new(title: title, edit_link: edit_link, id: "job_location")) }

    it "renders the heading" do
      expect(rendered_component).to include(title)
      expect(inline_component.css("a.review-component__section-button").to_html).to include(edit_link)
      expect(inline_component.css("#job_location_heading").count).to eq(1)
      expect(inline_component.css("[aria-label='Change job location']").count).to eq(1)
    end
  end
end
