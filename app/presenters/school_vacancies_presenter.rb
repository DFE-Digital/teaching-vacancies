class SchoolVacanciesPresenter < BasePresenter
  attr_reader :vacancy_type, :school, :sort, :vacancies

  def initialize(school, sort, vacancy_type)
    @vacancy_type = vacancy_type&.to_sym || :published
    @school = school
    @sort = sort
    raise ArgumentError unless self.class.valid_types.include?(@vacancy_type)

    @vacancies = send(@vacancy_type).map { |v| SchoolVacancyPresenter.new(v) }
  end

  def self.valid_types
    %i[published pending draft expired]
  end

  private

  def draft
    sort_vacancies(@school.vacancies.draft)
  end

  def pending
    sort_vacancies(@school.vacancies.pending)
  end

  def expired
    sort_vacancies(@school.vacancies.expired)
  end

  def published
    sort_vacancies(@school.vacancies.live)
  end

  def sort_vacancies(vacancies)
    vacancies = vacancies.sort_by { |vacancy| vacancy[sort.column] }
    vacancies = vacancies.reverse! if sort.order == 'desc'

    vacancies
  end
end