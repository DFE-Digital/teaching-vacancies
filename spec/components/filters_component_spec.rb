require "rails_helper"

RSpec.describe FiltersComponent, type: :component do
  let(:form) { instance_double(GOVUKDesignSystemFormBuilder::FormBuilder) }
  let(:options) { { remove_buttons: true, close_all: true } }
  let(:filters) { { total_count: 2 } }
  let(:items) do
    [
      { title: "Group 1", key: "group_1", options: [%w[option_1 OPTION_1]], selected: %w[option_1], value_method: :first, selected_method: :last },
      { title: "Group 2", key: "group_2", options: [%w[option_1 OPTION_1]], selected: %w[option_1], value_method: :first, selected_method: :last },
    ]
  end

  let(:kwargs) do
    {
      form: form,
      filters: filters,
      items: items,
      options: options,
    }
  end

  before do
    allow(form).to receive(:govuk_submit)
    allow(form).to receive(:govuk_collection_check_boxes)
  end

  subject! { render_inline(described_class.new(**kwargs)) }

  context "when there are selected filters" do
    it "renders filter remove UI" do
      expect(subject.css(".filters-component__remove").to_html).not_to be_blank
    end

    it "renders filter remove buttons for the selected filters" do
      expect(subject.css(".filters-component__remove .govuk-heading-s").to_html).to include("Group 1")
      expect(subject.css(".filters-component__remove .govuk-heading-s").to_html).to include("Group 2")
    end
  end

  context "when there are no selected filters" do
    let(:filters) { {} }
    let(:options) { { remove_buttons: true, close_all: true } }
    let(:items) do
      [
        { title: "Group 1", key: "group_1", options: [%w[option_1 OPTION_1]], selected: [], value_method: :first, selected_method: :last },
      ]
    end

    it "filters remove UI is not visible" do
      expect(subject.css(".filters-component__remove").to_html).to be_blank
      expect(subject.css(".filters-component__remove .govuk-heading-s").to_html).to be_blank
      expect(subject.css(".filters-component__heading-applied").to_html).to be_blank
    end
  end

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"
end
