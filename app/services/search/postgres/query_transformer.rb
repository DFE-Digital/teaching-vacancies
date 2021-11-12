# After a query has been parsed by `QueryParser`, transform it into an Arel node tree
class Search::Postgres::QueryTransformer < Parslet::Transform
  rule(plain_term: simple(:term)) do |captures|
    to_tsquery(:plain, captures[:term])
  end

  rule(synonym_term: simple(:term)) do |captures|
    synonyms = Rails.application.config.x.search.synonyms
      .find { |set| set.include?(captures[:term].to_s) }
    any_phrase_query(synonyms)
  end

  rule(oneway_synonym_term: simple(:term)) do |captures|
    oneway_synonyms = Rails.application.config.x.search.oneway_synonyms[captures[:term].to_s]
    any_phrase_query([captures[:term]] + oneway_synonyms)
  end

  rule(query: sequence(:terms)) do |captures|
    captures[:terms]
      .reduce { |acc, term| Arel::Nodes::InfixOperation.new("&&", acc, term) }
      .then { |query| Arel::Nodes::Grouping.new(query) }
  end

  def self.any_phrase_query(phrases)
    phrases
      .map { |syn| to_tsquery(:phrase, syn) }
      .reduce { |acc, term| Arel::Nodes::InfixOperation.new("||", acc, term) }
      .then { |query| Arel::Nodes::Grouping.new(query) }
  end

  def self.to_tsquery(type, word)
    Arel::Nodes::NamedFunction.new(
      "#{type}to_tsquery",
      [Arel::Nodes::Quoted.new("simple"), Arel::Nodes::Quoted.new(word.to_s)],
    )
  end
end
