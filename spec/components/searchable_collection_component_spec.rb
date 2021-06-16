require "rails_helper"

RSpec.describe SearchableCollectionComponent, type: :component do
  let(:form) { instance_double(GOVUKDesignSystemFormBuilder::FormBuilder) }

  let(:collection) { [1, 2, 3, 4, 5].freeze }

  before do
    allow(form).to receive(:govuk_collection_radio_buttons)
    allow(form).to receive(:govuk_collection_check_boxes)
  end

  let(:variant_mapping) { { radiobutton: :govuk_collection_radio_buttons, checkbox: :govuk_collection_check_boxes }}

  let(:base) do
    {
      form: form,
      attribute_name: :attributes,
      collection: collection,
      text_method: :first,
      hint_method: :first,
      value_method: :first,
    }
  end

  let(:kwargs) { { collection: collection, form: form, attribute_name: :attributes, text_method: :first, hint_method: :first, value_method: :first } }

  [:radiobutton, :checkbox].each do |variant|

    it_behaves_like "a component that accepts custom classes", variant, :with_variant
    it_behaves_like "a component that accepts custom HTML attributes", variant, :with_variant

    context "when initialised with a variant" do
      subject! { render_inline(described_class.new(**kwargs).with_variant(variant)) }

      it "the correct formbuilder collection is used" do
        expect(form).to have_received(variant_mapping[variant])
      end
    end
  end

  context "when using an item threshold of higher than collection size" do
    let(:options) { { threshold: 10 } }
    let(:radio_collection) do
      described_class.new(base.merge(options)).with_variant(:checkbox)
    end

    let!(:inline_component) { render_inline(radio_collection) }

    it "collection is not searchable" do
      expect(radio_collection.searchable).to be_falsey
      expect(inline_component.css(".searchable-collection-component__search")).to be_blank
      expect(inline_component.css(".searchable-collection-component--border")).to be_blank
    end

    it "collection items are large size" do
      expect(radio_collection.small).to be_falsey
    end

    it "collection is not scrollable" do
      expect(radio_collection.scrollable).to be_falsey
    end
  end

  context "when using an item threshold of lower or equal than collection size" do
    let(:options) { { threshold: 5 } }

    let(:checkbox_collection) do
      described_class.new(base.merge(options)).with_variant(:checkbox)
    end

    let!(:inline_component) { render_inline(checkbox_collection) }

    it "collection is searchable" do
      expect(checkbox_collection.searchable).to be_truthy
      expect(inline_component.css(".searchable-collection-component__search").count).to eq(1)
      expect(inline_component.css(".searchable-collection-component--border").count).to eq(1)
    end

    it "collection items are small size" do
      expect(checkbox_collection.small).to be_truthy
    end

    it "collection is scrollable" do
      expect(checkbox_collection.scrollable).to be_truthy
    end
  end
end
