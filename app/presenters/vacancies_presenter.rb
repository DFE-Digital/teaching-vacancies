class VacanciesPresenter < BasePresenter

  def initialize(vacancies)
    @decorated_collection = vacancies.map {|v| VacancyPresenter.new(v) }
    super(vacancies)
  end

  def decorated_collection
    @decorated_collection
  end

  def each(&block)
    decorated_collection.each(&block)
  end
end
