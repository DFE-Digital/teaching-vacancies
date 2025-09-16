class Publishers::CandidateMessagesController < Publishers::BaseController
  def index
    @tab = params[:tab] || "inbox"

    organisations_conversations = Conversation.for_organisation(current_organisation.id)
                                              .with_latest_message_date
                                              .includes(job_application: :vacancy, messages: :sender)
                                              .order(latest_message_at: :desc)

    @conversations = @tab == "archive" ? organisations_conversations.archived : organisations_conversations.inbox

    @inbox_count = Conversation.for_organisation(current_organisation.id)
                               .inbox
                               .with_unread_jobseeker_messages
                               .count
  end

  def toggle_archive
    conversation_ids = params[:conversations] || []

    Conversation.for_organisation(current_organisation.id)
                .where(id: conversation_ids)
                .update_all(archived: params[:archive_action] == "archive")

    if params[:archive_action] == "archive"
      redirect_to publishers_candidate_messages_path(tab: "archive"), notice: t(".archived")
    else
      redirect_to publishers_candidate_messages_path, notice: t(".unarchived")
    end
  end
end
