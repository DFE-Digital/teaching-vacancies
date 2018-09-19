module VacanciesHelper
  def salary_options
    (20000..70000).step(10000).map { |num| [number_to_currency(num), num] }.to_h
  end

  def working_pattern_options
    Vacancy.working_patterns.keys.map { |key| [key.humanize, key] }
  end

  def school_phase_options
    School.phases.keys.map { |key| [key.humanize, key] }
  end

  def link_to_sort_by(title, column:, order:, sort:)
    if column == sort.column
      order = sort.reverse_order
      active_class = ' active'
    end
    link_to title,
            jobs_path(vacancy_params(sort_column: column,
                                     sort_order: order)),
            class: "sortby--#{order}#{active_class || ''}",
            'aria-label': "Sort jobs by #{title} in #{order}ending order"
  end

  def vacancy_params_whitelist
    %i[sort_column sort_order location keyword minimum_salary
       maximum_salary working_pattern phase page]
  end

  def vacancy_params(overwrite = {})
    params.merge(overwrite).permit(vacancy_params_whitelist)
  end

  def rating_options
    [['Very satisfied', 5],
     ['Satisfied', 4],
     ['Neither satisfied or dissatisfied', 3],
     ['Dissatisfied', 2],
     ['Very dissatisfied', 1]]
  end

  def radius_filter_options
    [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80, 90, 100, 200].inject([]) do |radii, radius|
      radii << ["Within #{radius} miles", radius]
    end
  end

  def pay_scale_options
    @pay_scale_options ||= PayScale.all
  end

  def nqt_suitable_checked?(newly_qualified_teacher)
    newly_qualified_teacher == 'true'
  end
end
