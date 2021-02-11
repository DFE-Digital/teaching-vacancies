class UpdateAlgoliaIndex < ActiveJob::Base
  queue_as :low

  def perform
    Vacancy.update_index!
  end
end
