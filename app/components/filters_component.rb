class FiltersComponent < GovukComponent::Base
  attr_accessor :filters, :submit_button, :options, :title

  def self.variants
    %w[default]
  end

  def initialize(submit_button:, options:, filters: {}, title: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes.merge({ data: { controller: "filters" } }))

    @submit_button = submit_button
    @options = options
    @filters = filters
    @title = title
  end

  renders_many :groups, lambda { |key:, component:, title: nil|
    tag.div(key, class: "filters-component__groups__group", data: { "filters-target": "group", group: key }) do
      safe_join([
        (tag.h3(title, class: "govuk-fieldset__legend govuk-fieldset__legend--s") if title),
        tag.div(component),
      ].compact)
    end
  }

  renders_one :remove_buttons, "RemoveButtons"

  class RemoveButtons < ApplicationComponent
    def initialize(classes: [], html_attributes: {})
      super(classes: classes, html_attributes: html_attributes)
    end

    renders_many :groups, lambda { |selected:, key:, options:, value_method:, selected_method:, legend: false|
      if selected&.any?
        safe_join([
          tag.h4(legend, class: "govuk-heading-s"),
          tag.ul(class: "filters-component__remove-tags") do
            options.collect do |option|
              next unless selected.include?(option.public_send(value_method))

              concat(tag.li do
                tag.button(class: "filters-component__remove-tags__tag icon icon--left icon--cross", data: { action: "click->filters#remove", group: key, key: option.public_send(value_method) }) do
                  safe_join([tag.span(t("shared.filter_group.remove_filter_hidden"), class: "govuk-visually-hidden"),
                             option.public_send(selected_method)])
                end
              end)
            end
          end,
        ])
      end
    }
  end

  def display_remove_buttons?
    options[:remove_buttons] && filters[:total_count]&.positive?
  end

  def default_classes
    %w[filters-component]
  end
end
