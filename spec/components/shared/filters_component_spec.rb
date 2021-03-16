require "rails_helper"

RSpec.describe Shared::FiltersComponent, type: :component do
  let(:form) { instance_double(GOVUKDesignSystemFormBuilder::FormBuilder) }

  before do
    allow(form).to receive(:govuk_submit)
    allow(form).to receive(:govuk_collection_check_boxes)
    let(:kwargs) do
      {
        form: form,
        filters: { total_count: 2 },
        items: [
          { title: "Group 1", key: "group_1", options: [%w[option_1 OPTION_1]], selected: %w[option_1], value_method: :first, selected_method: :last },
          { title: "Group 2", key: "group_2", options: [%w[option_1 OPTION_1]], selected: %w[option_1], value_method: :first, selected_method: :last },
        ],
        options: { remove_buttons: true, close_all: true } }
    end
  end

  context "when there are selected filters" do
    subject do
      described_class.new(**kwargs)
    end

    let!(:inline_component) { render_inline(subject) }

    it "renders filter remove UI" do
      expect(inline_component.css(".moj-filter__content").to_html).not_to be_blank
    end

    it "renders filter remove buttons for the selected filters" do
      expect(inline_component.css(".moj-filter__content .govuk-heading-s").to_html).to include("Group 1")
      expect(inline_component.css(".moj-filter__content .govuk-heading-s").to_html).to include("Group 2")
    end

    it "renders count of number of filters applied" do
      expect(inline_component.css(".filters-component__heading-applied").to_html).to include("(2 applied)")
    end
  end

  context "when there are no selected filters" do
    subject do
      described_class.new(
        form: form,
        filters: {},
        items: [
          { title: "Group 1", key: "group_1", options: [%w[option_1 OPTION_1]], selected: [], value_method: :first, selected_method: :last },
        ],
        options: { remove_buttons: true, close_all: true },
      )
    end

    let!(:inline_component) { render_inline(subject) }

    it "filters remove UI is not visible" do
      expect(inline_component.css(".moj-filter__content").to_html).to be_blank
      expect(inline_component.css(".moj-filter__content .govuk-heading-s").to_html).to be_blank
      expect(inline_component.css(".filters-component__heading-applied").to_html).to be_blank
    end
  end

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"
end
