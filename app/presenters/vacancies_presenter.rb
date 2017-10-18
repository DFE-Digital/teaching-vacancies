class VacanciesPresenter < BasePresenter
  attr_reader :decorated_collection

  def initialize(vacancies)
    @decorated_collection = vacancies.map { |v| VacancyPresenter.new(v) }
    super(vacancies)
  end

  def each(&block)
    decorated_collection.each(&block)
  end
end
