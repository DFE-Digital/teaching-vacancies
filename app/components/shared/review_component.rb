class Shared::ReviewComponent < GovukComponent::Base
  attr_accessor :id, :title, :edit_link, :summary

  def initialize(id:, title:, edit_link: nil, summary: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @id = id
    @title = title
    @edit_link = edit_link
    @summary = summary
  end

  private

  def default_classes
    %w[review-component]
  end
end
