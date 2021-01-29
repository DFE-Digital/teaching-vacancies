class Shared::SearchableCollectionComponent < ViewComponent::Base
  attr_accessor :form, :attribute_name, :collection, :value_method, :text_method, :hint_method, :threshold

  def initialize(form:, attribute_name:, collection:, value_method:, text_method:, hint_method:, threshold: 10)
    @form = form
    @threshold = threshold
    @attribute_name = attribute_name
    @collection = collection
    @value_method = value_method
    @text_method = text_method
    @hint_method = hint_method

    @small = searchable
  end

  def searchable
    collection.count >= threshold
  end
end
