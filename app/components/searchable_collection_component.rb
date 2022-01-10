class SearchableCollectionComponent < GovukComponent::Base
  attr_accessor :form, :input_type, :label_text, :attribute_name, :collection, :value_method, :text_method, :hint_method, :threshold, :small, :scrollable

  # rubocop:disable Metrics/ParameterLists
  def initialize(form:, input_type:, attribute_name:, collection:, value_method:, text_method:, hint_method:, threshold: 10, scrollable: false, label_text: nil, classes: [], html_attributes: {})
    # rubocop:enable Metrics/ParameterLists
    super(classes:, html_attributes:)

    @form = form
    @input_type = input_type
    @label_text = label_text
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
    return "searchable-collection-component--scrollable" if scrollable
  end

  def border_class
    return "searchable-collection-component--border" if searchable
  end

  private

  def default_classes
    %w[searchable-collection-component]
  end
end
