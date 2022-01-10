require "rails_helper"

RSpec.describe SearchableCollectionComponent, type: :component do
  let(:form) { instance_double(GOVUKDesignSystemFormBuilder::FormBuilder) }

  let(:collection) { [1, 2, 3, 4, 5].freeze }

  before do
    allow(form).to receive(:govuk_collection_radio_buttons)
    allow(form).to receive(:govuk_collection_check_boxes)
  end

  let(:base) do
    {
      form:,
      input_type:,
      label_text: "search colllection",
      attribute_name: :attributes,
      collection:,
      text_method: :first,
      hint_method: :first,
      value_method: :first,
    }
  end

  let(:kwargs) { { collection:, form:, input_type: :checkbox, attribute_name: :attributes, text_method: :first, hint_method: :first, value_method: :first } }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when using an item threshold of higher than collection size" do
    let(:input_type) { :radio_button }
    let(:options) { { threshold: 10 } }
    let(:radio_collection) { described_class.new(**base.merge(options)) }

    let!(:inline_component) { render_inline(radio_collection) }

    it "is not searchable" do
      expect(radio_collection.searchable).to be_falsey
      expect(inline_component.css(".searchable-collection-component__search")).to be_blank
      expect(inline_component.css(".searchable-collection-component--border")).to be_blank
    end

    it "has large collection items" do
      expect(radio_collection.small).to be_falsey
    end

    it "is not scrollable" do
      expect(radio_collection.scrollable).to be_falsey
    end
  end

  context "when using an item threshold of lower or equal than collection size" do
    let(:input_type) { :checkbox }
    let(:options) { { threshold: 5 } }

    let(:checkbox_collection) { described_class.new(**base.merge(options)) }

    let!(:inline_component) { render_inline(checkbox_collection) }

    it "is searchable" do
      expect(checkbox_collection.searchable).to be_truthy
      expect(inline_component.css(".searchable-collection-component__search").count).to eq(1)
      expect(inline_component.css(".searchable-collection-component--border").count).to eq(1)
    end

    it "has aria label to describe collection to search" do
      expect(inline_component.css(".searchable-collection-component__search-input").attribute("aria-label").value).to eq("search colllection")
    end

    it "has small collection items" do
      expect(checkbox_collection.small).to be_truthy
    end

    it "is scrollable" do
      expect(checkbox_collection.scrollable).to be_truthy
    end
  end
end
