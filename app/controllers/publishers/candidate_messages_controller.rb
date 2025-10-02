class Publishers::CandidateMessagesController < Publishers::BaseController
  def index
    @tab = params[:tab] || "inbox"
    organisation_ids = current_publisher.accessible_organisations(current_organisation).map(&:id)

    base_conversations = Conversation.for_organisations(organisation_ids)
                                    .includes(job_application: :vacancy, messages: :sender)
                                    .ordered_by_unread_and_latest_message

    @conversations = @tab == "archive" ? base_conversations.archived : base_conversations.inbox

    @inbox_count = Conversation.for_organisations(organisation_ids)
                               .inbox
                               .with_unread_jobseeker_messages
                               .count
  end

  def toggle_archive
    conversation_ids = params[:conversations] || []
    organisation_ids = current_publisher.accessible_organisations(current_organisation).map(&:id)

    Conversation.for_organisations(organisation_ids)
                .where(id: conversation_ids)
                .update_all(archived: params[:archive_action] == "archive")

    if params[:archive_action] == "archive"
      redirect_to publishers_candidate_messages_path(tab: "archive"), notice: t(".archived")
    else
      redirect_to publishers_candidate_messages_path, notice: t(".unarchived")
    end
  end
end
