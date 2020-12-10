module SortHelper
  def table_header_sort_by(heading, column:, sort:)
    order = column == sort.column ? sort.reverse_order : sort.order
    extra_classes = "sortby--#{order}"
    extra_classes += " active" if column == sort.column

    govuk_link_to(heading, "#{request.path}?#{params_with_sort(column, order).to_query}",
                  class: "sortable-link #{extra_classes}",
                  'aria-label': t("jobs.aria_labels.sort_by_link", column: heading, order: order))
  end

  def params_with_sort(column, order)
    params.merge(sort_column: column, sort_order: order).permit(:sort_column, :sort_order)
  end
end
