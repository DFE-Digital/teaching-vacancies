class VacancyDetailsComponent < ViewComponent::Base
  def initialize(vacancy:)
    @vacancy = vacancy
  end
end
