class Jobseekers::JobApplicationHeadingComponent < ViewComponent::Base
  attr_reader :vacancy, :back_path

  def initialize(vacancy:, back_path:)
    @vacancy = vacancy
    @back_path = back_path
  end
end
