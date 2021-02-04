class Shared::SearchableCollectionComponent < ViewComponent::Base
  attr_accessor :form, :attribute_name, :collection, :value_method, :text_method, :hint_method, :threshold, :small, :scrollable

  def initialize(form:, attribute_name:, collection:, value_method:, text_method:, hint_method:, threshold: 10, scrollable: false)
    @form = form
    @threshold = threshold
    @attribute_name = attribute_name
    @collection = collection
    @value_method = value_method
    @text_method = text_method
    @hint_method = hint_method

    @small = searchable
    @scrollable = scrollable || searchable
  end

  def searchable
    collection.count >= threshold
  end

  def scrollable_class
    return "collection-component--scrollable" if scrollable
  end

  def border_class
    return "collection-component--border" if searchable
  end
end
