class Jobseekers::JobApplicationHeadingComponent < ViewComponent::Base
  attr_reader :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
  end
end
