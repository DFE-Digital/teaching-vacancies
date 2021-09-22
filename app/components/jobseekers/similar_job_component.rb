class Jobseekers::SimilarJobComponent < ViewComponent::Base
  include OrganisationsHelper

  attr_reader :vacancy

  with_collection_parameter :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
  end
end
