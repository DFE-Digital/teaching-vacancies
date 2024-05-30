class VacancyLocationQuery < LocationQuery
  def initialize(scope = Vacancy.all)
    @scope = scope
  end

  def call(...)
    super("vacancies.geolocation", ...)
  end
end
