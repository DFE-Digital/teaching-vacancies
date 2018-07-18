class VacanciesPresenter < BasePresenter
  attr_reader :decorated_collection, :searched

  def initialize(vacancies, searched:)
    @decorated_collection = vacancies.map { |v| VacancyPresenter.new(v) }
    @searched = searched
    super(vacancies)
  end

  def each(&block)
    decorated_collection.each(&block)
  end

  def total_count_message
    if total_count == 1
      return I18n.t('jobs.job_count_without_search', count: total_count) unless @searched
      I18n.t('jobs.job_count', count: total_count)
    else
      return I18n.t('jobs.job_count_plural_without_search', count: total_count) unless @searched
      I18n.t('jobs.job_count_plural', count: total_count)
    end
  end

  private def total_count
    model.total_count
  end
end
