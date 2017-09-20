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
end
