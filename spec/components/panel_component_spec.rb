require "rails_helper"

RSpec.describe PanelComponent, type: :component do
  let(:kwargs) { { panel_id: "panel-id", button_text: "button-text", heading_text: "heading text" } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  it "renders a button with the correct text" do
    expect(subject.css(".panel-component__toggle").to_html).to include("button-text")
  end

  it "renders a button with the correct data-panel-id html attribute" do
    expect(subject.css(".panel-component__toggle").to_html).to include("data-panel-id=\"panel-id\"")
  end

  it "renders a heading with the correct text" do
    expect(subject.css(".govuk-heading-m").to_html).to include("heading text")
  end
end
