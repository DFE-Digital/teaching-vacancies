class Search::KeywordQueryBuilder
  ONE_WAY_SYNONYMS = {
    'sats' => ['ks1', 'ks2']
  }

  TWO_WAY_SYNONYMS = [
    ['maths', 'mathematics', 'math']
  ].freeze

  def initialize(query_string)
    @query_string = query_string
  end

  def to_search_query(allow_synonyms: true)
    tokens.map { |token| to_tsquery(token, allow_synonyms: allow_synonyms) }.join(" && ")
  end

  def to_ranking
    # Rank results preferring the original query even when using two-way synonyms
    Arel.sql("ts_rank(searchable, #{to_search_query(allow_synonyms: false)}) DESC")
  end

  private

  def to_tsquery(token, allow_synonyms: true)
    if allow_synonyms
      ONE_WAY_SYNONYMS.each do |original, synonyms|
        return to_or_tsquery([original] + synonyms) if token == original
      end

      TWO_WAY_SYNONYMS.each do |synonym_row|
        return to_or_tsquery(synonym_row) if token.in?(synonym_row)
      end
    end
    "'#{token}'::tsquery"
  end

  def to_or_tsquery(synonyms)
    "(#{synonyms.map { |option| "'#{option}'::tsquery" }.join(" || ")})"
  end

  def tokens
    @query_string.downcase.split
  end
end
