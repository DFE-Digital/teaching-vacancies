class Shared::SearchableCollectionCheckboxesComponent < ViewComponent::Base
  attr_accessor :form, :attribute_name, :collection, :value_method, :text_method, :hint_method

  def initialize(form:, attribute_name:, collection:, value_method:, text_method:, hint_method:)
    @form = form
    @attribute_name = attribute_name
    @collection = collection
    @value_method = value_method
    @text_method = text_method
    @hint_method = hint_method
  end
end
