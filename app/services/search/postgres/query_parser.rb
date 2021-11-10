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
  rule(:space) { match('\s').repeat(1) }
  rule(:term_terminator) { match("$") | space }

  rule(:synonym_term) { synonym_atoms.reduce(:|).as(:synonym_term) >> term_terminator }
  rule(:oneway_synonym_term) { oneway_synonym_atoms.reduce(:|).as(:oneway_synonym_term) >> term_terminator }
  rule(:plain_term) { match('\S').repeat(1).as(:plain_term) >> term_terminator }

  rule(:term) { synonym_term | oneway_synonym_term | plain_term }

  rule(:query) { (space | term).repeat(0).as(:query) }

  root(:query)

  def synonym_atoms
    Rails.application.config.x.search.terms_with_synonyms.map { |s| str(s) }
  end

  def oneway_synonym_atoms
    Rails.application.config.x.search.terms_with_oneway_synonyms.map { |s| str(s) }
  end
end
