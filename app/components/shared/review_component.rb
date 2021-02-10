class Shared::ReviewComponent < ViewComponent::Base
  attr_accessor :edit_link, :title, :id

  def initialize(edit_link:, title:, id:)
    @edit_link = edit_link
    @title = title
    @id = id
  end
end
