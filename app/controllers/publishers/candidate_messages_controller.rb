class Publishers::CandidateMessagesController < Publishers::BaseController
  def index
    @tab = params[:tab] || "inbox"

    base_conversations = Conversation.for_organisation(current_organisation.id)
                                    .includes(job_application: :vacancy, messages: :sender)
                                    .with_latest_message_date

    filtered_conversations = @tab == "archive" ? base_conversations.archived : base_conversations.inbox

    # Sort conversations: unread first (newest first), then read (newest first)
    @conversations = filtered_conversations.sort_by do |conversation|
      has_unread = conversation.has_unread_messages_for_publishers?
      latest_message_time = conversation.latest_message_at

      # Return array for sorting: [unread_priority, -timestamp]
      # Unread conversations get priority 0, read get priority 1
      # Negative timestamp for descending order (newest first)
      [has_unread ? 0 : 1, -latest_message_time.to_i]
    end

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
