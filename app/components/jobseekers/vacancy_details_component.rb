class Jobseekers::VacancyDetailsComponent < ViewComponent::Base
  attr_accessor :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
  end
end
