class Search::KeywordFilterGeneration::QueryParser < Parslet::Parser
  root(:query)

  rule(:query) { (space | term).repeat(0).as(:query) }

  rule(:space) { match('\s').repeat(1) }

  rule(:term) { filterable_term | plain_term }
  rule(:term_terminator) { match("$") | space }

  rule(:filterable_term) { filterable_term_tokens.as(:filterable_term) >> term_terminator }

  rule(:plain_term) do
    match('\S').repeat(1) >> term_terminator
  end

  # Convenience method to parse and transform in one step
  def self.filters_from_query(query)
    parsed_query = new.parse(query)
    Search::KeywordFilterGeneration::QueryTransformer.apply(parsed_query)
  end

  def filterable_term_tokens
    Rails.application.config.x.search.keyword_filter_mapping_triggers
      .map { |s| str(s) }
      .reduce(:|)
  end

  def parse(query)
    super(query.downcase.delete("."))
  end
end
