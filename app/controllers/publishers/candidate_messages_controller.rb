class Publishers::CandidateMessagesController < Publishers::BaseController
  def index # rubocop:disable Metrics/AbcSize
    @tab = params[:tab] || "inbox"
    organisation_ids = current_publisher.accessible_organisations(current_organisation).map(&:id)
    @search_form = Publishers::CandidateMessagesSearchForm.new(search_params)
    @sort = Publishers::CandidateMessagesSort.new.update(sort_by: params[:sort_by] || "unread_on_top")

    base_conversations = Conversation.for_organisations(organisation_ids).includes(job_application: :vacancy, messages: :sender)

    filtered_conversations = @tab == "archive" ? base_conversations.archived : base_conversations.inbox

    conversations = Search::CandidateMessagesSearch.new(@search_form.to_hash, sort: @sort, scope: filtered_conversations).conversations
    @total_count = conversations.count
    @pagy, @conversations = pagy(conversations, limit: 15)

    @inbox_count = Conversation.for_organisations(organisation_ids).inbox.with_unread_jobseeker_messages.count
  end

  def toggle_archive
    conversation_ids = params[:conversations] || []
    organisation_ids = current_publisher.accessible_organisations(current_organisation).map(&:id)

    Conversation.for_organisations(organisation_ids)
                .where(id: conversation_ids)
                # distinct(false) is used here to avoid a PG::InvalidColumnReference error when the query is executed. This is because the update_all method does not support DISTINCT queries, and the conversation_ids array may contain duplicate values. By using distinct(false), we ensure that the query does not include a DISTINCT clause, which allows the update_all method to execute without errors.
                .distinct(false)
                .update_all(archived: params[:archive_action] == "archive")

    if params[:archive_action] == "archive"
      redirect_to publishers_candidate_messages_path(tab: "archive"), notice: t(".archived")
    else
      redirect_to publishers_candidate_messages_path, notice: t(".unarchived")
    end
  end

  private

  def search_params
    params.permit(:keyword, :sort_by)
  end
end
