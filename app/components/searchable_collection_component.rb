class SearchableCollectionComponent < ApplicationComponent
  attr_accessor :collection, :collection_count, :threshold, :border, :label_text, :options, :scrollable

  def initialize(collection:, collection_count:, options: {}, text: {}, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes.merge({ data: { controller: "searchable-collection" } }))

    @collection = collection
    @threshold = options[:threshold] || 10
    @text = text
    @border = options[:border] || false
    @collection_count = collection_count
    @scrollable = options[:scrollable] || searchable?
  end

  def searchable?
    collection_count >= threshold
  end

  def scrollable_class
    "searchable-collection-component--scrollable" if scrollable
  end

  def border_class
    return nil unless border

    "searchable-collection-component--border" if searchable?
  end

  private

  def default_classes
    %w[searchable-collection-component]
  end
end
