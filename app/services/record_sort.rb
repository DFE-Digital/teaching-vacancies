class RecordSort
  attr_reader :column, :order

  def initialize
    @column = default_column
    @order = default_order
  end

  def update(column:, order:)
    @column = column if valid_sort_columns.include?(column)
    @order = order if valid_sort_orders.include?(order)
    self
  end

  def reverse_order
    @order == "asc" ? "desc" : "asc"
  end

  def valid_sort_orders
    %w[desc asc].freeze
  end
end
