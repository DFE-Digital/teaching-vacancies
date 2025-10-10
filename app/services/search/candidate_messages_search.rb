class Search::CandidateMessagesSearch
  attr_reader :search_criteria, :keyword, :original_scope

  def initialize(search_criteria, scope:)
    @search_criteria = search_criteria
    @keyword = search_criteria[:keyword]
    @original_scope = scope
  end

  def active_criteria
    search_criteria.compact_blank
  end

  def active_criteria?
    active_criteria.any?
  end

  def conversations
    @conversations ||= scope
  end

  def total_count
    @total_count ||= conversations.count
  end

  private

  def scope
    if keyword.present?
      # Remove any existing distinct to allow pg to sort by the computed ts_rank values and order by relevance
      base_scope = original_scope.except(:distinct)
      base_scope.search_by_keyword(keyword)
    else
      # When not searching, use the original scope with its default ordering
      original_scope
    end
  end
end
