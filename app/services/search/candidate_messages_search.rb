class Search::CandidateMessagesSearch
  attr_reader :search_criteria, :keyword, :scope

  def initialize(search_criteria, scope:)
    @search_criteria = search_criteria
    @keyword = search_criteria[:keyword]
    @scope = scope
  end

  def active_criteria
    search_criteria.compact_blank
  end

  def active_criteria?
    active_criteria.any?
  end

  def conversations
    @conversations ||= if keyword.present?
                         scope_ids = Conversation.search_ids_by_keyword(keyword)
                         scope.where(id: scope_ids)
                       else
                         scope
                       end
  end

  def total_count
    @total_count ||= conversations.count
  end
end
