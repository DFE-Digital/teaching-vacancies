class SetOrganisationSlugsJob < ApplicationJob
  queue_as :default

  def perform
    Organisation.find_each(batch_size: 100, &:save)
  end
end
