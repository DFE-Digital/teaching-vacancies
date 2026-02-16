class VacancyLocationQuery < LocationQuery
  def initialize(scope)
    @scope = scope
  end

  def call(...)
    super("vacancies.uk_geolocation", ...)
  end
end
