class SearchableCollectionComponent < ViewComponent::Base
  SEARCHABLE_THRESHOLD = 10

  attr_accessor :form, :attribute_name, :collection, :value_method, :text_method, :hint_method, :small, :scrollable

  def initialize(form:, attribute_name:, collection:, value_method:, text_method:, hint_method:, scrollable: false)
    @form = form
    @attribute_name = attribute_name
    @collection = collection
    @value_method = value_method
    @text_method = text_method
    @hint_method = hint_method

    @small = searchable
    @scrollable = scrollable || searchable
  end

  def searchable
    collection.count >= SEARCHABLE_THRESHOLD
  end

  def scrollable_class
    return "searchable-collection-component--scrollable" if scrollable
  end

  def border_class
    return "searchable-collection-component--border" if searchable
  end
end
