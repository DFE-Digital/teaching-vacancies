class VacancyFullTextSearchQuery < ApplicationQuery
  attr_reader :scope

  def initialize(scope = Vacancy.live)
    @scope = scope
  end

  def call(query)
    # Convert user input into a search query of Postgres type `tsquery`
    # TODO: `websearch_to_tsquery` used to get this up and running quickly, to be replaced soon
    #       with custom query logic taking synonyms etc into account.
    tsquery = Arel::Nodes::NamedFunction.new(
      "websearch_to_tsquery",
      [
        Arel::Nodes::Quoted.new("simple"),
        Arel::Nodes::Quoted.new(query),
      ],
    )

    full_text_query = Arel::Nodes::InfixOperation.new(
      "@@",
      scope.arel_table[:searchable_content],
      tsquery,
    )

    rank_order = Arel::Nodes::NamedFunction.new(
      "ts_rank",
      [scope.arel_table[:searchable_content], tsquery],
    )

    # Order based on "relevance" (`ts_rank`) here because we don't have access to the `tsquery`
    # outside of this query object. If the user chooses a different search order, the call to
    # `reorder` in `PgSearch` will take precedence over this order. `order` does not directly
    # take an Arel object, so convert it to a SQL string and mark it as safe using `Arel.sql`.
    scope.where(full_text_query).order(Arel.sql(rank_order.to_sql) => :desc)
  end
end
