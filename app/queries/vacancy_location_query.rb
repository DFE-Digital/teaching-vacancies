class VacancyLocationQuery < LocationQuery
  def initialize(scope = Vacancy.live)
    @scope = scope
  end

  def call(...)
    super("vacancies.geolocation", ...)
  end
end
