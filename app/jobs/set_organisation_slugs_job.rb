class SetOrganisationSlugsJob < ApplicationJob
  queue_as :default

  def perform
    Organisation.where(slug: nil).find_each(batch_size: 500, &:save)
  end
end
