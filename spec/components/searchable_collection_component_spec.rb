require "rails_helper"

RSpec.describe SearchableCollectionComponent, type: :component do
  let(:subject) { described_class.new(**base.merge!(options)) }

  let(:form) { instance_double(GOVUKDesignSystemFormBuilder::FormBuilder) }
  let(:collection) { [1, 2, 3, 4, 5].freeze }
  let(:options) { { threshold: 10, input_type: :radio_button } }

  let(:inline_component) { render_inline(subject) }

  before do
    allow(form).to receive(:govuk_collection_radio_buttons)
    allow(form).to receive(:govuk_collection_check_boxes)
  end

  let(:base) do
    {
      form: form,
      label_text: "search colllection",
      attribute_name: :attributes,
      collection: collection,
      text_method: :first,
      hint_method: :first,
      value_method: :first,
    }
  end

  let(:kwargs) { { collection: collection, form: form, input_type: :checkbox, attribute_name: :attributes, text_method: :first, hint_method: :first, value_method: :first } }

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
    let(:options) { { threshold: collection.size, input_type: :checkbox } }

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

  context "when the size of the collection items required has not been not specified" do
    before { allow(subject).to receive(:searchable?).and_return(false) }

    it "sets small to nil" do
      expect(subject.small).to be_nil
    end

    it "sets the size of the collection items to the value returned by #searchable?" do
      expect(subject.small_items?).to eq(false)
    end
  end

  context "when the size of the collection items required is specified" do
    context "when small is true" do
      before { options.merge!(small: true)}

      it "sets the size of the collection items to be small" do
        expect(subject.small_items?).to be_truthy
      end
    end

    context "when small is false" do
      before { options.merge!(small: false)}

      it "sets the size of the collection items to be large" do
        expect(subject.small_items?).to be_falsey
      end
    end
  end

  context "when the input type provided is :radio_button" do
    it "renders a collection of radio buttons" do
      expect(form).to receive(:govuk_collection_radio_buttons)

      render_inline(subject)
    end
  end

  context "when the input type provided is :checkbox" do
    before { options.merge!(input_type: :checkbox)}

    it "renders a collection of checkboxes" do
      expect(form).to receive(:govuk_collection_check_boxes)

      render_inline(subject)
    end
  end
end
