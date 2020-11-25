class Publishers::NoVacanciesComponent < ViewComponent::Base
  def initialize(organisation:)
    @organisation = organisation
  end

  def render?
    @organisation.all_vacancies.active.none?
  end
end
