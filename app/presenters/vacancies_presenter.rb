class VacanciesPresenter < BasePresenter
  attr_reader :decorated_collection

  def initialize(vacancies)
    @decorated_collection = vacancies.map { |v| VacancyPresenter.new(v) }
    super(vacancies)
  end

  def each(&block)
    decorated_collection.each(&block)
  end

  def pluralize_vacancy_count(count, i18n_id, plural_i18n_id = nil)
    if count == 1
      I18n.t(i18n_id, count: count)
    else
      I18n.t(plural_i18n_id || (i18n_id + '_plural'), count: count)
    end
  end
end
