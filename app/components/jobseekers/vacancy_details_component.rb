class Jobseekers::VacancyDetailsComponent < ViewComponent::Base
  delegate :open_in_new_tab_link_to, to: :helpers

  attr_accessor :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
  end
end
