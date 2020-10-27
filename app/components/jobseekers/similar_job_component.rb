class Jobseekers::SimilarJobComponent < ViewComponent::Base
  include OrganisationHelper

  attr_accessor :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
  end
end
