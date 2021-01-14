class Jobseekers::SimilarJobComponent < ViewComponent::Base
  include OrganisationHelper

  attr_reader :vacancy

  with_collection_parameter :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
  end
end
