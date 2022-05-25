class SetOrganisationSlugsOfBatchJob < ApplicationJob
  queue_as :default

  def perform(ids)
    Organisation.where(id: ids).find_each(batch_size: 50, &:save)
  end
end
