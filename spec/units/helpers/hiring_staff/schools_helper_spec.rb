require 'rails_helper'

RSpec.describe HiringStaff::SchoolsHelper, type: :helper do
  describe '#table_header_sort_by' do
    it 'returns a link to the hiring staff index with the new parameters' do
      sort = VacancySort.new
      result = helper.table_header_sort_by('foo', 'pending', column: 'job_title', sort: sort)

      expect(result).to eq(
        '<a class="govuk-link sortable-link sortby--asc" aria-label="Sort jobs by foo in ascending order" '\
        'href="/school/jobs/pending?sort_column=job_title&amp;sort_order=asc">foo</a>'
      )
    end

    context 'the current sort column is the same as the given column' do
      it 'outputs an active class and reverses the sort order' do
        sort = VacancySort.new(default_column: 'job_title', default_order: 'asc')
        result = helper.table_header_sort_by('foo', 'published', column: 'job_title', sort: sort)

        expect(result).to eq(
          '<a class="govuk-link sortable-link sortby--desc active" aria-label="Sort jobs by foo in descending order" '\
          'href="/school/jobs?sort_column=job_title&amp;sort_order=desc">foo</a>'
        )
      end
    end
  end
end
