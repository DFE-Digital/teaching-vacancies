class VacanciesFinder
  attr_reader :vacancies

  def initialize(filters, sort, page_number)
    @filters = filters
    @sort = sort
    @page_number = page_number
    @vacancies = VacanciesPresenter.new(records, searched: search_filters_given?)
  end

  private

  attr_reader :filters, :sort, :page_number

  def search_filters_given?
    @search_filters_given ||= filters.any?
  end

  def records
    search_filters_given? ? search_results : all_vacancies
  end

  def search_results
    Vacancy.public_search(filters: filters, sort: sort)
           .page(page_number)
           .records(includes: [:school])
  end

  def all_vacancies
    Vacancy.live
           .order(sort.column => sort.order)
           .includes(:school)
           .page(page_number)
  end
end