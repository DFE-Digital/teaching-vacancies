class VacanciesPresenter < BasePresenter
  attr_reader :decorated_collection

  def initialize(vacancies)
    @decorated_collection = vacancies.map { |v| VacancyPresenter.new(v) }
    super(vacancies)
  end

  def each(&block)
    decorated_collection.each(&block)
  end

  def total_count(i18n_id = 'vacancies.vacancy_count')
    return I18n.t(i18n_id, count: model.total_entries) if model.total_entries == 1
    I18n.t("#{i18n_id}_plural", count: model.total_entries)
  end
end
