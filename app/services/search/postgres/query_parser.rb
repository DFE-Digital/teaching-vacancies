# Parses a user's search query into a syntax tree which can later be transformed into an Arel AST
#
# We use a managed Postgres database through GOV.UK PaaS and it does not support custom synonym
# dictionaries for full-text search (because we do not get filesystem access on the database
# server which Postgres requires for loading dictionaries). This means we can't just add a
# synonym dictionary/thesaurus to Postgres, use `websearch_to_tsquery`, and call it a day - instead
# we need to parse our own queries and take synonyms into account when doing so.
#
# The silver lining is we have full control over query parsing and can implement arbitrary query
# syntax in the future.

class Search::Postgres::QueryParser < Parslet::Parser
  root(:query)

  rule(:query) { (space | term).repeat(0).as(:query) }

  rule(:space) { match('\s').repeat(1) }

  rule(:term) { synonym_term | oneway_synonym_term | plain_term }
  rule(:term_terminator) { match("$") | space } # Ensures that

  rule(:synonym_term) do
    synonym_token.as(:synonym_term) >> term_terminator
  end
  rule(:oneway_synonym_term) do
    oneway_synonym_token.as(:oneway_synonym_term) >> term_terminator
  end
  rule(:plain_term) do
    match('\S').repeat(1).as(:plain_term) >> term_terminator
  end

  # Represents any phrase that occurs in the synonym dictionary as a static string token
  def synonym_token
    Rails.application.config.x.search.terms_with_synonyms
      .map { |s| str(s) }.reduce(:|)
  end

  # Represents any phrase that occurs in the oneway synonym dictionary as a static string token
  def oneway_synonym_token
    Rails.application.config.x.search.terms_with_oneway_synonyms
      .map { |s| str(s) }.reduce(:|)
  end

  # Normalise query before parsing
  def parse(query)
    super(query.downcase)
  end
end
