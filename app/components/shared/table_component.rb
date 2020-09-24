class Shared::TableComponent < ViewComponent::Base
  attr_accessor :rows

  def initialize(rows:)
    @rows = rows
  end
end
