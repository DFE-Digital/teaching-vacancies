class FiltersComponent < ApplicationComponent
  attr_accessor :filters, :submit_button, :options, :title

  def initialize(submit_button:, options:, filters: {}, clear_filters_link: {}, title: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes.merge({ data: { controller: "filters" } }))

    @submit_button = submit_button
    @options = options
    @filters = filters
    @clear_filters_link = clear_filters_link
    @title = title
  end

  def clear_filters_link
    govuk_link_to @clear_filters_link[:text], @clear_filters_link[:url], method: @clear_filters_link[:method]
  end

  renders_many :groups, lambda { |key:, component:, title: nil|
    tag.div(key, class: "filters-component__groups__group", data: { "filters-target": "group", group: key }) do
      safe_join([
        (tag.h3(title, class: "govuk-fieldset__legend govuk-fieldset__legend--s") if title),
        tag.div(component),
      ].compact)
    end
  }

  renders_one :remove_filter_links, "RemoveFilterLinks"

  class RemoveFilterLinks < ApplicationComponent
    def initialize(classes: [], html_attributes: {})
      super(classes: classes, html_attributes: html_attributes)
    end

    def filter_link(selected, key, option, value_method, selected_method, remove_filter_link)
      filter_value = option.public_send(value_method)
      return unless selected.include?(filter_value)

      if remove_filter_link[:params]
        filters = remove_filter_link[:params][key] - [filter_value]
        remove_filter_link_params = remove_filter_link[:params].merge(key => filters)
      else
        remove_filter_link_params = { filter_id: filter_value }
      end
      remove_filter_url = public_send(remove_filter_link[:url_helper], remove_filter_link_params)
      filter_label = option.public_send(selected_method)
      hidden_text = tag.span(t("shared.filter_group.remove_filter_hidden"), class: "govuk-visually-hidden")
      accessible_label = safe_join [hidden_text, filter_label]
      classes = "filters-component__remove-tags__tag icon icon--left icon--cross"
      govuk_link_to accessible_label, remove_filter_url, class: classes, no_underline: true, text_colour: true
    end

    renders_many :groups, lambda { |selected:, key:, options:, value_method:, selected_method:, remove_filter_link: {}, legend: false|
      if selected&.any?
        tag.div(key, class: "filters-component__remove-group") do
          safe_join([
            tag.h4(legend, class: "govuk-heading-s"),
            tag.ul(class: "filters-component__remove-tags") do
              options.each do |option|
                link = filter_link(selected, key, option, value_method, selected_method, remove_filter_link)
                concat(tag.li { link }) if link
              end
            end,
          ])
        end
      end
    }
  end

  def display_remove_filter_links?
    options[:remove_filter_links] && filters[:total_count]&.positive?
  end

  def default_classes
    %w[filters-component]
  end
end
