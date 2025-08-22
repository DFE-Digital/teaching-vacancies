class Publishers::CandidateMessagesController < Publishers::BaseController
  before_action :check_current_organisation

  def index
    @tab = params[:tab] || 'inbox'
    
    # Count inbox messages for tab label (do this first for efficiency)
    @inbox_count = JobApplication.joins(:vacancy, conversations: :messages)
                                 .where(vacancies: { publisher_organisation_id: current_organisation.id })
                                 .where(conversations: { archived: false })
                                 .distinct
                                 .count('job_applications.id')
    
    # Get job application IDs ordered by latest message time, filtered by archive status
    conversations_scope = case @tab
                         when 'archive'
                           Conversation.archived
                         else
                           Conversation.inbox
                         end

    job_application_ids = JobApplication.joins(:vacancy, conversations: :messages)
                                        .where(vacancies: { publisher_organisation_id: current_organisation.id })
                                        .where(conversations: { id: conversations_scope.select(:id) })
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

  def archive
    conversation_ids = params[:conversations] || []
    
    if conversation_ids.empty?
      redirect_back(fallback_location: publishers_candidate_messages_path, alert: 'Please select at least one conversation to archive.')
      return
    end

    conversations = Conversation.joins(job_application: :vacancy)
                                .where(id: conversation_ids, vacancies: { publisher_organisation_id: current_organisation.id })

    archived_count = 0
    conversations.each do |conversation|
      if conversation.update(archived: true)
        archived_count += 1
      end
    end

    redirect_to publishers_candidate_messages_path, notice: "#{archived_count} conversation(s) archived successfully."
  end

  def unarchive
    conversation_ids = params[:conversations] || []
    
    if conversation_ids.empty?
      redirect_back(fallback_location: publishers_candidate_messages_path(tab: 'archive'), alert: 'Please select at least one conversation to unarchive.')
      return
    end

    conversations = Conversation.joins(job_application: :vacancy)
                                .where(id: conversation_ids, vacancies: { publisher_organisation_id: current_organisation.id })

    unarchived_count = 0
    conversations.each do |conversation|
      if conversation.update(archived: false)
        unarchived_count += 1
      end
    end

    redirect_to publishers_candidate_messages_path(tab: 'archive'), notice: "#{unarchived_count} conversation(s) unarchived successfully."
  end

  private

  def check_current_organisation
    redirect_to root_path unless current_organisation
  end
end