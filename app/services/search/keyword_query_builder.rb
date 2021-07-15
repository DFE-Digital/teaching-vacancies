class Search::KeywordQueryBuilder
  # https://www.postgresql.org/docs/12/functions-textsearch.html
  # TODO:
  #   - rank based on original query again
  #   - deal with one way synonyms again
  #   - deal with non-synonyms
  #   - tidy all this the hell up

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

    def to_tsquery_without_synonyms
      to_tsquery
    end

    def to_tsquery
      phrase_query = token_string.split.map { |word|
        "'#{word}'::tsquery"
      }.join(" <-> ")

      "(#{phrase_query})"
    end
  end

  class SynonymToken
    attr_reader :tokens, :original_token

    def initialize(tokens, original_token)
      @tokens = tokens
      @original_token = original_token
    end

    def to_tsquery_without_synonyms
      original_token.to_tsquery
    end

    def to_tsquery
      "(#{tokens.map(&:to_tsquery).join(' || ')})"
    end
  end

  def initialize(query_string)
    @query_string = query_string
  end

  def to_search_query
    tokens.map(&:to_tsquery).join(" && ")
  end

  def to_ranking
    # Rank results preferring the original query even when using two-way synonyms
    Arel.sql("ts_rank(searchable, #{tokens.map(&:to_tsquery_without_synonyms).join(' && ')}) DESC")
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
          tokens.push(SynonymToken.new(synonyms.map { |t| Token.new(t) }, Token.new(synonym)))
          ""
        end
      end
    end

    ONE_WAY_SYNONYMS.each do |original, synonyms|
      str.gsub!(original) do
        tokens.push(
          SynonymToken.new(
            synonyms.map { |t| Token.new(t) } + [Token.new(original)],
            Token.new(original),
          )
        )
        ""
      end
    end

    @tokens = tokens + str.split.map { |t| Token.new(t) }
  end
end
