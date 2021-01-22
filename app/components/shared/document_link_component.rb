class Shared::DocumentLinkComponent < ViewComponent::Base
  attr_reader :document

  with_collection_parameter :document

  def initialize(document:)
    @document = document
  end
end
