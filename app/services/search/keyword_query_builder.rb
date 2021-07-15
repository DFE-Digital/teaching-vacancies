class Search::KeywordQueryBuilder
  ONE_WAY_SYNONYMS = {
    "sats" => %w[ks1 ks2],
  }.freeze

  TWO_WAY_SYNONYMS = [
    %w[maths mathematics math],
    ["modern foreign languages", "mfl"],
  ].freeze

  NON_SYNONYMS = {
    "science" => "computer science",
  }.freeze

  class Token
    attr_reader :token_string

    def initialize(token_string)
      @token_string = token_string.downcase
    end

    def to_tsquery(allow_synonyms: true)
      if allow_synonyms
        ONE_WAY_SYNONYMS.each do |original, synonyms|
          return to_or_tsquery([original] + synonyms) if token_string == original
        end

        TWO_WAY_SYNONYMS.each do |synonym_row|
          return to_or_tsquery(synonym_row) if token_string.in?(synonym_row)
        end
      end

      "'#{token_string}'::tsquery"
    end

    def to_or_tsquery(synonyms)
      "(#{synonyms.map { |option| "'#{option}'::tsquery" }.join(' || ')})"
    end
  end

  # https://www.postgresql.org/docs/12/functions-textsearch.html
  # We need to account for multiword tokens like the new synonyms above
  # This applies to all synonym types
  # <->

  def initialize(query_string)
    @query_string = query_string
  end

  def to_search_query(allow_synonyms: true)
    tokens.map { |token| token.to_tsquery(allow_synonyms: allow_synonyms) }.join(" && ")
  end

  def to_ranking
    # Rank results preferring the original query even when using two-way synonyms
    Arel.sql("ts_rank(searchable, #{to_search_query(allow_synonyms: false)}) DESC")
  end

  private

  def tokens
    @query_string.split.map { |t| Token.new(t) }
  end
end
