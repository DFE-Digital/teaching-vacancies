class HiringStaff::NoVacanciesComponent < ViewComponent::Base
  def initialize(organisation:)
    @organisation = organisation
  end

  def render?
    @organisation.vacancies.active.none?
  end
end
