class SearchableCollectionComponent < GovukComponent::Base
  attr_accessor :form, :input_type, :attribute_name, :collection, :value_method, :text_method, :hint_method, :threshold, :border, :small, :label_text, :form_group, :options, :scrollable

  # rubocop:disable Metrics/ParameterLists
  def initialize(form:, input_type:, attribute_name:, collection:, value_method:, text_method:, hint_method:, threshold: 10, border: true, small: nil, options: {}, form_group: {}, scrollable: false, label_text: nil, classes: [], html_attributes: {})
    # rubocop:enable Metrics/ParameterLists
    super(classes: classes, html_attributes: html_attributes)

    @form = form
    @attribute_name = attribute_name
    @collection = collection
    @value_method = value_method
    @text_method = text_method
    @hint_method = hint_method
    @form_group = form_group

    @input_type = input_type
    @threshold = threshold
    @label_text = label_text
    @border = border
    @small = small
    @options = options
    @scrollable = scrollable || searchable?
  end

  def searchable?
    collection.count >= threshold
  end

  def small_items?
    return searchable? if small.nil?

    small
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
