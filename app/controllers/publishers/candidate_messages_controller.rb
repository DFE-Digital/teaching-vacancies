class Publishers::CandidateMessagesController < Publishers::BaseController
  before_action :check_current_organisation

  def index
    # Get job application IDs ordered by latest message time
    job_application_ids = JobApplication.joins(:vacancy, conversations: :messages)
                                        .where(vacancies: { publisher_organisation_id: current_organisation.id })
                                        .group('job_applications.id')
                                        .order('MAX(messages.created_at) DESC')
                                        .pluck(:id)
    
    # Get the job applications in the correct order
    @conversations = JobApplication.where(id: job_application_ids)
                                   .includes(:conversations, :jobseeker, :vacancy)
                                   .index_by(&:id)
                                   .values_at(*job_application_ids)
                                   .compact
  end

  private

  def check_current_organisation
    redirect_to root_path unless current_organisation
  end
end