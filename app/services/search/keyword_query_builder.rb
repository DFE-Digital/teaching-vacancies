class Search::KeywordQueryBuilder
  def initialize(query_string)
    @query_string = query_string
  end

  def to_sql
    tokens.map { |token|
      if token == "music"
        "('music'::tsquery || 'maths'::tsquery)"
      else
        "'#{token}'::tsquery"
      end
    }.join(" && ")
  end

  def tokens
    @query_string.split
  end
end
