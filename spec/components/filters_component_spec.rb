require "rails_helper"

RSpec.describe FiltersComponent, type: :component do
  let(:form) { instance_double(GOVUKDesignSystemFormBuilder::FormBuilder) }
  let(:options) { { remove_buttons: true } }
  let(:filters) { { total_count: 2 } }
  let(:clear_filters_link) { { text: "clear", url: "/clear-all", method: :post } }

  let(:kwargs) do
    {
      submit_button: form.govuk_submit("apply filters"),
      filters: filters,
      options: options,
      clear_filters_link: clear_filters_link,
    }
  end

  before do
    allow(form).to receive(:govuk_submit)
    allow(form).to receive(:govuk_collection_check_boxes)
  end

  context "when there are selected filters" do
    subject! do
      render_inline(described_class.new(**kwargs)) do |c|
        c.remove_buttons do |rb|
          rb.group(key: "group_two", legend: "Group 2", options: [%w[filter_1 FILTER1], %w[filter_2 FILTER2]], value_method: :first, selected_method: :last, selected: %w[filter_2])
        end
        c.group key: "group_one", component: form.govuk_collection_check_boxes(:group_one, [%w[filter_1 FILTER1], %w[filter_2 FILTER2]], :first, :last, small: true, legend: { text: "Group 1" }, hint: nil)
        c.group key: "group_two", component: form.govuk_collection_check_boxes(:group_two, [%w[filter_1 FILTER1], %w[filter_2 FILTER2]], :first, :last, small: true, legend: { text: "Group 2" }, hint: nil)
      end
    end

    it "renders filter remove UI" do
      expect(subject.css(".filters-component__remove").to_html).not_to be_blank
      expect(page).to have_link("clear", href: "/clear-all")
    end

    it "renders filter remove buttons for the selected filters" do
      expect(subject.css(".filters-component__remove .govuk-heading-s").to_html).to include("Group 2")
      expect(subject.css(".filters-component__remove .filters-component__remove-tags__tag").to_html).to include("FILTER2")
    end
  end

  context "when there are no selected filters" do
    let(:filters) { {} }
    let(:options) { { remove_buttons: true } }

    subject! do
      render_inline(described_class.new(**kwargs)) do |c|
        c.remove_buttons do |rb|
          filter_types.each do |_filter_type|
            rb.group(selected: [], options: [%w[filter_1 FILTER1], %w[filter_2 FILTER2]])
          end
        end
        c.group key: "group_one", component: form.govuk_collection_check_boxes(:group_one, [%w[filter_1 FILTER1], %w[filter_2 FILTER2]], :first, :last, small: true, legend: { text: "Group 1" }, hint: nil)
        c.group key: "group_two", component: form.govuk_collection_check_boxes(:group_two, [%w[filter_1 FILTER1], %w[filter_2 FILTER2]], :first, :last, small: true, legend: { text: "Group 2" }, hint: nil)
      end
    end

    it "filters remove UI is not visible" do
      expect(subject.css(".filters-component__remove").to_html).to be_blank
    end
  end

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"
end
