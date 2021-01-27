class UpdateAlgoliaIndex < ApplicationJob
  queue_as :low

  def perform
    Vacancy.update_index!
  end
end
