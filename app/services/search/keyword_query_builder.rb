class Search::KeywordQueryBuilder
  def initialize(query_string)
    @query_string = query_string
  end

  def to_sql
    tokens.map { |token| "'#{token}'::tsquery" }.join(" && ")
  end

  def tokens
    @query_string.split
  end
end
