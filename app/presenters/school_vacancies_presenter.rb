class SchoolVacanciesPresenter < BasePresenter
  attr_reader :vacancy_type
  attr_reader :school

  def initialize(school, vacancy_type)
    @vacancy_type = vacancy_type&.to_sym || :published
    @school = school
    raise ArgumentError unless self.class.valid_types.include?(@vacancy_type)
  end

  def self.valid_types
    %i[published pending draft expired]
  end

  def draft
    @school.vacancies.draft
  end

  def pending
    @school.vacancies.pending
  end

  def expired
    @school.vacancies.expired
  end

  def published
    @school.vacancies.live
  end
end