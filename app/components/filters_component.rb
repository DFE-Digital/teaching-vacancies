class FiltersComponent < GovukComponent::Base
  attr_accessor :filters, :form, :items, :options

  def self.variants
    %w[default]
  end

  def initialize(filters:, form:, items:, options:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @filters = filters
    @form = form
    @items = items
    @options = options
  end

  def render?
    filters.present?
  end

  def display_remove_buttons?
    filters[:total_count].positive? && options[:remove_buttons]
  end

  def mobile_modifier(selector)
    options[:mobile_variant] ? "#{selector}--mobile" : selector
  end

  def default_classes
    ["filters-component"].tap do |applied_classes|
      applied_classes.push(mobile_modifier("filters-component")) if options[:mobile_variant]
    end
  end
end
