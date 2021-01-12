class RecordSort
  include Enumerable
  attr_reader :column, :order

  delegate :each, to: :options

  SortOption = Struct.new(:column, :order, :display_name)

  def update(column:)
    @column = column if valid_sort_columns.include?(column)
    @order = options.detect { |option| option.column == column }.order if valid_sort_columns.include?(column)
    self
  end
end
