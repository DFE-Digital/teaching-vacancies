# frozen_string_literal: true

class Search::CandidateMessagesSearch
  attr_reader :search_criteria, :keyword, :original_scope, :current_tab

  def initialize(search_criteria, scope:, current_tab: "inbox")
    @search_criteria = search_criteria
    @keyword = search_criteria[:keyword]
    @original_scope = scope
    @current_tab = current_tab
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

  def clear_filters_params
    { tab: current_tab }
  end

  private

  def scope
    if keyword.present?
      # When searching, use pg_search which handles its own ordering
      # Remove any existing distinct to avoid ORDER BY conflicts
      base_scope = original_scope.except(:distinct)
      base_scope.search_by_keyword(keyword)
    else
      # When not searching, use the original scope with its default ordering
      original_scope
    end
  end
end
