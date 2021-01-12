class RecordSort
  include Enumerable
  attr_reader :column, :order

  delegate :each, to: :options

  SortOption = Struct.new(:column, :order, :display_name)

  def update(column:)
    @column = column if options.map(&:column).include?(column)
    @order = options.detect { |option| option.column == column }.order if options.map(&:column).include?(column)
    self
  end
end
