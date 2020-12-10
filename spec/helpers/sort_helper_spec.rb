require "rails_helper"

RSpec.describe SortHelper, type: :helper do
  describe "#table_header_sort_by" do
    let(:heading) { "test_heading" }
    let(:column) { "test_column" }
    let(:sort) { VacancySort.new }
    let(:request) { double("request", path: "/test/test_path") }
    let(:result) { helper.table_header_sort_by(heading, column: column, sort: sort) }

    before { allow(helper).to receive(:request).and_return(request) }

    it "returns a link to the given path with the appended sort parameters" do
      expect(result).to eql(
        '<a class="govuk-link sortable-link sortby--asc" aria-label="Sort jobs by test_heading in ascending order" '\
        'href="/test/test_path?sort_column=test_column&amp;sort_order=asc">test_heading</a>',
      )
    end

    context "when the current sort column is the same as the given column" do
      let(:sort) { VacancySort.new.update(column: "expires_on", order: "asc") }
      let(:column) { "expires_on" }

      it "returns a link to the given path with the appended sort parameters, an active class and reversed sort order" do
        expect(result).to eql(
          '<a class="govuk-link sortable-link sortby--desc active" aria-label="Sort jobs by test_heading in descending order" '\
          'href="/test/test_path?sort_column=expires_on&amp;sort_order=desc">test_heading</a>',
        )
      end
    end
  end
end
