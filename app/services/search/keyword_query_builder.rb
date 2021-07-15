class Search::KeywordQueryBuilder
  ONE_WAY_SYNONYMS = {
    "sats" => %w[ks1 ks2],
  }.freeze

  TWO_WAY_SYNONYMS = [
    %w[maths mathematics math],
    ["modern foreign languages", "mfl"],
    ["computer science", "ict", "information technology"],
  ].freeze

  NON_SYNONYMS = {
    "science" => "computer science",
  }.freeze

  class Token
    attr_reader :token_string

    def initialize(token_string)
      @token_string = token_string
    end

    def to_tsquery
      phrase_query = token_string.split.map { |word|
        "'#{word}'::tsquery"
      }.join(" <-> ")

      "(#{phrase_query})"
    end
  end

  class OrToken
    attr_reader :tokens

    def initialize(tokens)
      @tokens = tokens
    end

    def to_tsquery
      "(#{tokens.map(&:to_tsquery).join(' || ')})"
    end
  end

  # https://www.postgresql.org/docs/12/functions-textsearch.html
  # We need to account for multiword tokens like the new synonyms above
  # This applies to all synonym types
  # <->

  def initialize(query_string)
    @query_string = query_string
  end

  def to_search_query
    tokens.map(&:to_tsquery).join(" && ")
  end

  def to_ranking
    # Rank results preferring the original query even when using two-way synonyms
    # Arel.sql("ts_rank(searchable, #{to_search_query(allow_synonyms: false)}) DESC")
    Arel.sql("publish_on DESC")
  end

  private

  # if allow_synonyms
  #   ONE_WAY_SYNONYMS.each do |original, synonyms|
  #     return to_or_tsquery([original] + synonyms) if token_string == original
  #   end

  #   TWO_WAY_SYNONYMS.each do |synonym_row|
  #     return to_or_tsquery(synonym_row) if token_string.in?(synonym_row)
  #   end
  # end
  def tokens
    return @tokens if @tokens

    str = @query_string.downcase
    tokens = []

    TWO_WAY_SYNONYMS.each do |synonyms|
      synonyms.each do |synonym|
        str.gsub!(synonym) do
          tokens.push(OrToken.new(synonyms.map { |t| Token.new(t) }))
          ""
        end
      end
    end

    @tokens = tokens + str.split.map { |t| Token.new(t) }
  end
end
