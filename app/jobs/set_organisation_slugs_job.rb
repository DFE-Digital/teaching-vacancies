class SetOrganisationSlugsJob < ApplicationJob
  queue_as :default

  def perform
    Organisation.where(slug: nil).find_each(&:save)
  end
end
