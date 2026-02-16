class SupportUsers::PublisherAtsApiClients::ConflictAttemptsController < SupportUsers::BaseController
  def index
    @api_client = PublisherAtsApiClient.find(params[:publisher_ats_api_client_id])
    conflict_attempts = @api_client.vacancy_conflict_attempts
                                   .includes(conflicting_vacancy: [:organisations, :publisher_ats_api_client])
                                   .ordered_by_latest

    @pagy, @conflict_attempts = pagy(conflict_attempts, items: 25)

    # Calculate total attempts across all conflicts
    @total_attempts = @api_client.vacancy_conflict_attempts.sum(:attempts_count)
    @total_conflicts = @api_client.vacancy_conflict_attempts.count
  end
end
