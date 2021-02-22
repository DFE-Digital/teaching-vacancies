require "rails_helper"

RSpec.describe Shared::CardComponent, type: :component do
  describe "renders correctly" do
    let!(:inline_component) do
      render_inline(described_class.new(id: "cosmic-id", classes: "cosmic-class", html_attributes: { "data-test": "cosmic" })) do |card|
        card.header_item(label: "header title", value: "header value")
        card.body_item(label: "body title", value: "body value")
        card.action_item(action: "action")
      end
    end

    it "adds HTML attributes, classes and id to the component container" do
      expect(inline_component.css(".card-component[data-test='cosmic']")).to_not be_blank
      expect(inline_component.css(".card-component.cosmic-class")).to_not be_blank
      expect(inline_component.css(".card-component#cosmic-id")).to_not be_blank
    end

    it "renders the heading" do
      expect(inline_component.css(".card-component__header .govuk-list li").text).to include("header title: header value")
      expect(inline_component.css(".card-component__header .govuk-list li").count).to eq(1)
    end

    it "renders the body" do
      expect(inline_component.css(".card-component__body .govuk-list li").text).to include("body title: body value")
      expect(inline_component.css(".card-component__body .govuk-list li").count).to eq(1)
    end

    it "renders the actions" do
      expect(inline_component.css(".card-component__actions .govuk-list li").text).to include("action")
      expect(inline_component.css(".card-component__actions .govuk-list li").count).to eq(1)
    end
  end
end
