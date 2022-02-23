class SearchableCollectionComponent < GovukComponent::Base
  attr_accessor :collection, :collection_count, :threshold, :border, :label_text, :options, :scrollable

  def initialize(collection:, collection_count:, options: {}, label_text: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @collection = collection
    @threshold = options[:threshold] || 10
    @label_text = label_text
    @border = options[:border] || false
    @collection_count = collection_count
    @scrollable = options[:scrollable] || searchable?
  end

  def searchable?
    collection_count >= threshold
  end

  def scrollable_class
    return "searchable-collection-component--scrollable" if scrollable
  end

  def border_class
    return nil unless border

    return "searchable-collection-component--border" if searchable?
  end

  private

  def default_classes
    %w[searchable-collection-component]
  end
end
