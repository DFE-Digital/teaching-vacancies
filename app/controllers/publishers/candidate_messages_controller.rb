class Publishers::CandidateMessagesController < Publishers::BaseController
  def index
    @tab = params[:tab] || "inbox"

    conversations_query = Conversation.joins(job_application: :vacancy)
                                     .where(vacancies: { publisher_organisation_id: current_organisation.id })
                                     .includes(job_application: :vacancy, messages: :sender)
                                     .joins(:messages)
                                     .group("conversations.id")
                                     .order("MAX(messages.created_at) DESC")

    @conversations = @tab == "archive" ? conversations_query.archived : conversations_query.inbox

    @inbox_count = conversations_query.inbox.count { |conversation| conversation.has_unread_messages_for_publishers? }
  end

  def toggle_archive
    conversation_ids = params[:conversations] || []

    Conversation.joins(job_application: :vacancy)
                .where(id: conversation_ids, vacancies: { publisher_organisation_id: current_organisation.id })
                .update_all(archived: params[:archive_action] == "archive")

    if params[:archive_action] == "archive"
      redirect_to publishers_candidate_messages_path(tab: "archive"), notice: t(".archived")
    else
      redirect_to publishers_candidate_messages_path, notice: t(".unarchived")
    end
  end
end
