require "rails_helper"

RSpec.describe SearchableCollectionComponent, type: :component do
  let(:subject) { described_class.new(**base.merge!(options)) }

  let(:form) { instance_double(GOVUKDesignSystemFormBuilder::FormBuilder) }
  let(:collection) { [1, 2, 3, 4, 5].freeze }
  let(:options) { {} }

  let(:inline_component) { render_inline(subject) }

  before do
    allow(form).to receive(:govuk_collection_check_boxes)
  end

  let(:base) do
    {
      label_text: "search colllection",
      collection: form.govuk_collection_check_boxes(:attributes,
                                                    collection,
                                                    :first,
                                                    :first,
                                                    :first),
      collection_count: collection.count,
    }
  end

  let(:kwargs) { { collection: collection, collection_count: collection.count } }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when providing an item threshold higher in number than the collection size" do
    it "is not searchable" do
      expect(subject.searchable?).to be_falsey
      expect(inline_component.css(".searchable-collection-component__search")).to be_blank
      expect(inline_component.css(".searchable-collection-component--border")).to be_blank
    end

    it "is not scrollable" do
      expect(subject.scrollable).to be_falsey
    end
  end

  context "when using an item threshold of lower or equal than collection size" do
    let(:options) { { options: { threshold: collection.size, border: true } } }

    it "is searchable" do
      expect(subject.searchable?).to be_truthy
      expect(inline_component.css(".searchable-collection-component__search").count).to eq(1)
      expect(inline_component.css(".searchable-collection-component--border").count).to eq(1)
    end

    it "has aria label to describe collection to search" do
      expect(inline_component.css(".searchable-collection-component__search-input").attribute("aria-label").value).to eq("search colllection")
    end

    it "is scrollable" do
      expect(subject.scrollable).to be_truthy
    end
  end
end
