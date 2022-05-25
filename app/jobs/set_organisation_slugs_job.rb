class SetOrganisationSlugsJob < ApplicationJob
  queue_as :default

  def perform
    Organisation.find_in_batches do |batch|
      SetOrganisationSlugsOfBatchJob.perform_later(batch.map(&:id))
    end
  end
end
