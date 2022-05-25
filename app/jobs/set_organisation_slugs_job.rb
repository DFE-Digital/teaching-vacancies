class SetOrganisationSlugsJob < ApplicationJob
  def perform
    Organisation.find_each { |organisation| organisation.save }
  end
end
