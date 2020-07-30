class VacancySort
  attr_reader :column, :order

  VALID_SORT_COLUMNS = %w[job_title readable_job_location expires_on starts_on publish_on created_at updated_at
                          total_pageviews total_get_more_info_clicks].freeze
  VALID_SORT_ORDERS = %w[desc asc].freeze

  def initialize(default_column: 'expires_on', default_order: 'asc')
    @column = default_column
    @order = default_order
  end

  def update(column:, order:)
    @column = VALID_SORT_COLUMNS.include?(column) ? column : @column
    @order = VALID_SORT_ORDERS.include?(order) ? order : @order
    self
  end

  def reverse_order
    @order == 'asc' ? 'desc' : 'asc'
  end
end
