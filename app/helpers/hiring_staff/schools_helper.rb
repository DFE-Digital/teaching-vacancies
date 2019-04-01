module HiringStaff::SchoolsHelper
  def table_header_sort_by(title, column:, sort:)
    if column == sort.column
      order = sort.reverse_order
      active_class = ' active'
    else
      order = sort.order
    end

    link_to title,
            jobs_with_type_school_path(school_vacancy_params(sort_column: column, sort_order: order)),
            class: "govuk-link sortable-link sortby--#{order}#{active_class || ''}",
            'aria-label': "Sort jobs by #{title} in #{order}ending order"
  end

  def school_vacancy_params_whitelist
    %i[sort_column sort_order]
  end

  def school_vacancy_params(overwrite = {})
    params.merge(overwrite).permit(school_vacancy_params_whitelist)
  end
end
