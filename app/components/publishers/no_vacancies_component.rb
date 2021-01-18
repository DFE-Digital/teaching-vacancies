class Publishers::NoVacanciesComponent < ViewComponent::Base
  def initialize(organisation:, email:)
    @organisation = organisation
    @email = email
  end

  def render?
    @organisation.all_vacancies.active.none?
  end
end
