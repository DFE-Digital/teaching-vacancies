class Search::Strategies::Database
  DEFAULT_ORDER = "publish_on DESC".freeze
  ORDER_OPTIONS = {
    publish_on_desc: "publish_on DESC",
    expires_at_desc: "expires_at DESC",
    expires_at_asc: "expires_at ASC",
  }.freeze

  attr_reader :total_count, :vacancies

  def initialize(page, per_page, jobs_sort)
    @page = page
    @per_page = per_page
    @jobs_sort = jobs_sort
    @order = build_order
    @vacancies = Vacancy.live.order(@order).page(@page).per(@per_page)
    @total_count = vacancies.total_count
  end

  private

  def build_order
    @jobs_sort.present? && ORDER_OPTIONS.key?(@jobs_sort.to_sym) ? ORDER_OPTIONS[@jobs_sort.to_sym] : DEFAULT_ORDER
  end
end
