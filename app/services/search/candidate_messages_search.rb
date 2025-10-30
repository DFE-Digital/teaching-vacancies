class Search::CandidateMessagesSearch
  attr_reader :search_criteria, :keyword, :sort, :scope

  def initialize(search_criteria, sort:, scope:)
    @search_criteria = search_criteria
    @keyword = search_criteria[:keyword]
    @sort = sort
    @scope = scope
  end

  def active_criteria
    search_criteria.compact_blank
  end

  def active_criteria?
    active_criteria.any?
  end

  def conversations
    filtered_scope = if keyword.present?
                       scope_ids = Conversation.search_ids_by_keyword(keyword)
                       scope.where(id: scope_ids)
                     else
                       scope
                     end

    apply_sorting(filtered_scope)
  end

  private

  def apply_sorting(filtered_scope)
    case sort.by
    when "newest_on_top"
      filtered_scope.order(last_message_at: :desc)
    when "oldest_on_top"
      filtered_scope.order(last_message_at: :asc)
    else # "unread_on_top"
      filtered_scope.ordered_by_unread_and_latest_message
    end
  end
end
