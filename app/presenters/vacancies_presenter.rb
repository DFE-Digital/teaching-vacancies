class VacanciesPresenter < BasePresenter
  attr_reader :decorated_collection

  def initialize(vacancies, searched:)
    @decorated_collection = vacancies.map { |v| VacancyPresenter.new(v) }
    @searched = searched
    super(vacancies)
  end

  def each(&block)
    decorated_collection.each(&block)
  end

  def total_count
    if model.total_count == 1
      return I18n.t('jobs.job_count_without_search', count: model.total_count) unless @searched
      I18n.t('jobs.job_count', count: model.total_count)
    else
      return I18n.t('jobs.job_count_plural_without_search', count: model.total_count) unless @searched
      I18n.t('jobs.job_count_plural', count: model.total_count)
    end
  end
end
