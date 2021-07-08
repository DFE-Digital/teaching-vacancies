class Search::Strategies::PgSearch
  attr_reader :page, :per_page

  def initialize(keyword, page:, per_page:)
    @keyword = keyword
    @page = page
    @per_page = per_page
  end

  def vacancies
    # TODO: Implement me
    Kaminari.paginate_array([], total_count: total_count).page(page).per(per_page)
  end

  def total_count
    # TODO: Implement me
    0
  end
end
