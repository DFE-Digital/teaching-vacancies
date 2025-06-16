# frozen_string_literal: true

module VacancyFilterQueryModule
  def vacancy_filter_query(filters)
    VacancyFilterQuery.new(all).call(filters)
  end
end
