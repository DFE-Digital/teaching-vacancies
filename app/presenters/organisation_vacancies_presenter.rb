class OrganisationVacanciesPresenter < BasePresenter
  attr_reader :vacancy_type, :organisation, :sort, :vacancies

  def initialize(organisation, sort, vacancy_type)
    @vacancy_type = vacancy_type&.to_sym || :published
    @organisation = organisation
    @sort = sort
    raise ArgumentError unless self.class.valid_types.include?(@vacancy_type)

    @vacancies = send(@vacancy_type).map { |v| OrganisationVacancyPresenter.new(v) }
  end

  def self.valid_types
    %i[published pending draft expired awaiting_feedback]
  end

  private

  def draft
    @organisation.vacancies.draft.order(sort.column => sort.order)
  end

  def pending
    @organisation.vacancies.pending.order(sort.column => sort.order)
  end

  def expired
    @organisation.vacancies.expired.order(sort.column => sort.order)
  end

  def published
    @organisation.vacancies.live.order(sort.column => sort.order)
  end

  def awaiting_feedback
    @organisation.vacancies.awaiting_feedback.order(sort.column => sort.order)
  end
end
