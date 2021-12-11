require "rails_helper"

RSpec.describe SortComponent, type: :component do
  let(:path) { Rails.application.routes.url_helpers.method(:page_path) }
  let(:url_params) { { id: "terms-and-conditions" } }
  let(:sort) do
    sort_class = Class.new(RecordSort)

    # rubocop:disable Style/DocumentDynamicEvalDefinition
    sort_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def options
        Array.new(#{number_of_sorting_options}) do |i|
          SortOption.new("sort_by_\#{i}", "sorting algorithm number \#{i + 1}")
        end
      end
    RUBY
    # rubocop:enable Style/DocumentDynamicEvalDefinition

    sort_class.new
  end
  let(:number_of_sorting_options) { 2 }
  let(:active_sort_option) { sort.options.first }

  let(:kwargs) { { path: path, sort: sort, url_params: url_params } }

  before do
    sort.update(sort_by: active_sort_option)
    render_inline(described_class.new(**kwargs))
  end

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when there are fewer than two sorting options available" do
    let(:number_of_sorting_options) { 1 }

    it "does not render" do
      expect(described_class.new(**kwargs).render?).to be_falsey
    end
  end

  context "when there are two sorting options available" do
    let(:number_of_sorting_options) { 2 }

    it "renders the list instead of the drop-down" do
      expect(page).to have_css("ul.accessible-sorting-component__list")
      expect(page).not_to have_css("select")
    end

    it "makes the inactive sort option into a link" do
      expect(page).to have_link("Sorting algorithm number 2", href: path.call(url_params.merge(sort_by: "sort_by_1")))
    end

    it "does not make the current sort option into a link" do
      expect(page).to have_content("Sorting algorithm number 1")
      expect(page).not_to have_link("Sorting algorithm number 1", href: path.call(url_params.merge(sort_by: "sort_by_0")))
    end
  end

  context "when there are more than two sorting options available" do
    let(:number_of_sorting_options) { 3 }

    it "renders the drop-down instead of the list" do
      expect(page).to have_css("select[name='sort_by']")
      expect(page).not_to have_css("ul")
    end

    it "points the form to the correct endpoint" do
      expect(page).to have_css("form[method='get'][action='/pages/#{url_params[:id]}']")
    end

    context "initializing SortForm" do
      let(:active_sort_option) { "sort_by_2" }

      it "selects the active sort option" do
        expect(page).to have_css("option[value='sort_by_2'][selected='selected']")
      end
    end
  end
end
