class VacancyFullTextSearchQuery < ApplicationQuery
  attr_reader :scope

  def initialize(scope = Vacancy.live)
    @scope = scope
  end

  def call(query)
    # Perform full text search on the searchable_content column using Postgres `@@` operator
    # TODO: `websearch_to_tsquery` used to get this up and running quickly, to be replaced soon
    #       with a custom query taking synonyms etc into account.
    full_text_query = Arel::Nodes::InfixOperation.new(
      "@@",
      scope.arel_table[:searchable_content],
      Arel::Nodes::NamedFunction.new(
        "websearch_to_tsquery",
        [Arel::Nodes::Quoted.new(query)],
      ),
    )

    scope.where(full_text_query)
  end
end
