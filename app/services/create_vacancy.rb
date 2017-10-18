class CreateVacancy
  def initialize(school:)
    @school = school
  end

  def call(params)
    vacancy = Vacancy.new(params)

    vacancy.status = :draft
    vacancy.school = @school
    vacancy.save

    vacancy
  end
end
