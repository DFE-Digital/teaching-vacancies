class Search::KeywordQueryBuilder
  TWO_WAY_SYNONYMS = [
    ['maths', 'mathematics', 'math']
  ].freeze

  def initialize(query_string)
    @query_string = query_string
  end

  def to_query(allow_synonyms: true)
    tokens.map { |token| to_tsquery(token, allow_synonyms: allow_synonyms) }.join(" && ")
  end

  def to_ranking
    # Rank results preferring the original query even when using two-way synonyms
    Arel.sql("ts_rank(searchable, #{to_query(allow_synonyms: false)}) DESC")
  end

  private

  def to_tsquery(token, allow_synonyms: true)
    if allow_synonyms
      TWO_WAY_SYNONYMS.each do |synonym_row|
        if token.in?(synonym_row)
          return "(#{synonym_row.map { |option| "'#{option}'::tsquery" }.join(" || ")})"
        end
      end
    end
    "'#{token}'::tsquery"
  end

  def tokens
    @query_string.split
  end
end
