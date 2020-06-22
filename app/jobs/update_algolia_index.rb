class UpdateAlgoliaIndex < ApplicationJob
  queue_as :update_algolia_index

  def perform
    Vacancy.update_index!
  end
end
