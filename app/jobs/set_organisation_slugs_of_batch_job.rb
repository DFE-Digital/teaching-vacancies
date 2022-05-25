class SetOrganisationSlugsOfBatchJob < ApplicationJob
  queue_as :default

  def perform(ids)
    Organisation.where(id: ids).each(&:save)
  end
end
