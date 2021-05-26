require "rails_helper"

RSpec.describe SearchableCollectionComponent, type: :component do
  let(:form) { instance_double(GOVUKDesignSystemFormBuilder::FormBuilder) }

  let(:collection) { Array.new(SearchableCollectionComponent::SEARCHABLE_THRESHOLD) { |i| i }.freeze }

  before do
    allow(form).to receive(:govuk_collection_radio_buttons)
    allow(form).to receive(:govuk_collection_check_boxes)
  end

  subject do
    described_class.new({ form: form,
                          attribute_name: :attributes,
                          collection: collection,
                          text_method: :first,
                          hint_method: :first,
                          value_method: :first }).with_variant(variant)
  end

  let!(:inline_component) { render_inline(subject) }

  context "when using radio button variant" do
    let(:variant) { :radiobutton }

    it "a formbuilder radio button collection is used" do
      expect(form).to have_received(:govuk_collection_radio_buttons)
    end

    it "is not searchable when collection is smaller than threshold" do
      expect(subject.searchable).to be_falsey
      expect(inline_component.css(".searchable-collection-component__search")).to be_blank
      expect(inline_component.css(".searchable-collection-component--border")).to be_blank
    end

    it "does not have small buttons when collection is smaller than threshold" do
      expect(subject.small).to be_falsey
    end

    it "container is not scrollable when collection is smaller than threshold" do
      expect(subject.scrollable).to be_falsey
    end
  end

  context "when using check box variant" do
    let(:variant) { :checkbox }

    it "a formbuilder checkbox collection is used" do
      expect(form).to have_received(:govuk_collection_check_boxes)
    end

    it "is searchable when collection size is equal to threshold" do
      expect(subject.searchable).to be_truthy
      expect(inline_component.css(".searchable-collection-component__search").count).to eq(1)
      expect(inline_component.css(".searchable-collection-component--border").count).to eq(1)
    end

    it "has buttons when collection size is equal to threshold" do
      expect(subject.small).to be_truthy
    end

    it "container is scrollable when collection size is equal to threshold" do
      expect(subject.scrollable).to be_truthy
    end
  end
end
