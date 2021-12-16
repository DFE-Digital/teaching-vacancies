class SortForm
  include ActiveModel::Model

  attr_reader :sort_column

  def initialize(sort)
    @sort_column = sort
  end
end
