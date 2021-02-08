class Search::VacancyPaginator
  DEFAULT_ORDER = "publish_on DESC".freeze
  ORDER_OPTIONS = {
    publish_on_desc: "publish_on DESC",
    expires_at_desc: "expires_at DESC",
    expires_at_asc: "expires_at ASC",
  }.freeze

  attr_reader :stats, :total_count, :vacancies

  def initialize(page, hits_per_page, jobs_sort)
    @page = page
    @hits_per_page = hits_per_page
    @jobs_sort = jobs_sort
    @order = build_order
    @vacancies = Vacancy.live.order(@order).page(@page).per(@hits_per_page)
    @stats = build_stats
    @total_count = vacancies.total_count
  end

  private

  def build_order
    @jobs_sort.present? && ORDER_OPTIONS.key?(@jobs_sort.to_sym) ? ORDER_OPTIONS[@jobs_sort.to_sym] : DEFAULT_ORDER
  end

  def build_stats
    return [0, 0, 0] if vacancies.total_count.zero? || vacancies.out_of_range?

    first_number = (vacancies.current_page - 1) * @hits_per_page + 1
    last_number = (vacancies.current_page - 1) * @hits_per_page + vacancies.count
    [first_number, last_number, vacancies.total_count]
  end
end
