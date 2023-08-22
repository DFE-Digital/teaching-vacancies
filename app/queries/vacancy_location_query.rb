class VacancyLocationQuery < LocationQuery
  def initialize(scope = Vacancy.live)
    @scope = scope
  end

  def call(*args)
    super("vacancies.geolocation", *args)
  end
end
