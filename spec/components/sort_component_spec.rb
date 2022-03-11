require "rails_helper"

RSpec.describe SortComponent, type: :component do
  let(:path) { Rails.application.routes.url_helpers.method(:page_path) }
  let(:url_params) { { id: "terms-and-conditions" } }
  let(:sort_klass) do
    Class.new(RecordSort) do
      attr_reader :options

      def initialize(options)
        @options = options
      end
    end
  end
  let(:sort) { sort_klass.new(sorting_options) }
  let(:sorting_options) do
    (1..number_of_sorting_options).map do |i|
      RecordSort::SortOption.new("sort_by_#{i}", "sorting algorithm number #{i}")
    end
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

  context "when there are four sorting options available" do
    let(:number_of_sorting_options) { 4 }

    it "renders the list instead of the drop-down" do
      expect(page).to have_css("ul.sort-component__list")
      expect(page).not_to have_css("select")
    end

    it "makes the inactive sort option into a link" do
      expect(page).to have_link("Sorting algorithm number 2", href: path.call(url_params.merge(sort_by: "sort_by_2")))
    end

    it "does not make the current sort option into a link" do
      expect(page).to have_content("Sorting algorithm number 1")
      expect(page).not_to have_link("Sorting algorithm number 1", href: path.call(url_params.merge(sort_by: "sort_by_1")))
    end
  end

  context "when there are more than four sorting options available" do
    let(:number_of_sorting_options) { 5 }

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
