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
    @conversations ||= if keyword.present?
                         # Deduplicate conversations that appear multiple times due to MAT/school relationships.
                         # We can't use DISTINCT at the SQL level because pg_search adds rank columns that
                         # conflict with PostgreSQL's DISTINCT/ORDER BY requirements, so we dedupe in Ruby.
                         scope.to_a.uniq(&:id)
                       else
                         scope
                       end
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
