class SetOrganisationSlugsJob < ApplicationJob
  def perform
    Organisation.where(slug: nil).find_each(&:save)
  end
end
