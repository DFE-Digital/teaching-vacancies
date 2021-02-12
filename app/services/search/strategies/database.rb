class Search::Strategies::Database
  def initialize(page, per_page, sort_by)
    @page = page
    @per_page = per_page
    @sort_by = sort_by
  end

  def vacancies
    @vacancies ||= Vacancy.live.order(@sort_by.column => @sort_by.order).page(@page).per(@per_page)
  end

  def total_count
    vacancies.total_count
  end
end
