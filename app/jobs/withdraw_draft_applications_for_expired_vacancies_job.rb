class WithdrawDraftApplicationsForExpiredVacanciesJob < ApplicationJob
  queue_as :low

  def perform
    JobApplication.joins(:vacancy)
                  .draft
                  .merge(Vacancy.expired)
                  .find_each { |ja| ja.update!(status: "withdrawn") }
  end
end
