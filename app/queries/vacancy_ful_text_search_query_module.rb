# frozen_string_literal: true

module VacancyFulTextSearchQueryModule
  def vacancy_full_text_search_query(query)
    VacancyFullTextSearchQuery.new(all).call(query)
  end
end
