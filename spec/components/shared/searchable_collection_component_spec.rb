require "rails_helper"

RSpec.describe Shared::SearchableCollectionComponent, type: :component do
  let(:form) { instance_double(GOVUKDesignSystemFormBuilder::FormBuilder) }

  let(:collection) { [1, 2, 3, 4, 5].freeze }

  before do
    allow(form).to receive(:govuk_collection_radio_buttons)
    allow(form).to receive(:govuk_collection_check_boxes)
  end

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

  context "when using radio button variant" do
    let(:options) { { threshold: 10 } }
    let(:radio_collection) do
      described_class.new(base.merge(options)).with_variant(:radiobutton)
    end

    let!(:inline_component) { render_inline(radio_collection) }

    it "a formbuilder radio button collection is used" do
      expect(form).to have_received(:govuk_collection_radio_buttons)
    end

    it "is not searchable when collection is smaller than threshold" do
      expect(radio_collection.searchable).to be_falsey
      expect(inline_component.css(".searchable-collection-component__search")).to be_blank
      expect(inline_component.css(".searchable-collection-component--border")).to be_blank
    end

    it "does not have small buttons when collection is smaller than threshold" do
      expect(radio_collection.small).to be_falsey
    end

    it "container is not scrollable when collection is smaller than threshold" do
      expect(radio_collection.scrollable).to be_falsey
    end
  end

  context "when using check box variant" do
    let(:options) { { threshold: 5 } }

    let(:checkbox_collection) do
      described_class.new(base.merge(options)).with_variant(:checkbox)
    end

    let!(:inline_component) { render_inline(checkbox_collection) }

    it "a formbuilder checkbox collection is used" do
      expect(form).to have_received(:govuk_collection_check_boxes)
    end

    it "is searchable when collection is equal to threshold" do
      expect(checkbox_collection.searchable).to be_truthy
      expect(inline_component.css(".searchable-collection-component__search").count).to eq(1)
      expect(inline_component.css(".searchable-collection-component--border").count).to eq(1)
    end

    it "has buttons when collection is equal to threshold" do
      expect(checkbox_collection.small).to be_truthy
    end

    it "container is scrollable when collection is equal to threshold" do
      expect(checkbox_collection.scrollable).to be_truthy
    end
  end
end
