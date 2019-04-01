class VacancySort
  attr_reader :column, :order

  VALID_SORT_COLUMNS = %w[job_title date_to_be_posted expires_on expired_on starts_on publish_on
                          page_views get_more_info_clicks draft.time_created draft.time_updated].freeze
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
