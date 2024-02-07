class VacancyFullTextSearchQuery < ApplicationQuery
  attr_reader :scope

  def initialize(scope = Vacancy.all)
    @scope = scope
  end

  def call(query)
    tsquery_arel = Search::Postgres::QueryParser.arel_from_query(query)

    full_text_query = Arel::Nodes::InfixOperation.new(
      "@@",
      scope.arel_table[:searchable_content],
      tsquery_arel,
    )

    scope.where(full_text_query)
  end
end
