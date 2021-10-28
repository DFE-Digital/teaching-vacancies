# Given a set of weighted values, generates a `tsvector` value that can be assigned to an
# appropriate column that can then be searched on using Postgres full-text search.
#
# see: https://www.postgresql.org/docs/13/textsearch-controls.html#TEXTSEARCH-PARSING-DOCUMENTS
class Search::Postgres::TsvectorGenerator
  # Create a new instance for a given hash of Postgres weights (:a, :b, :c, :d) to a value
  # (or array of values) to be indexed at this weight.
  #
  # e.g.:
  #   Search::TsvectorGenerator.new(a: "hello", b: ["goodbye", "what an interesting document"])
  def initialize(weighted_values)
    raise ArgumentError, "Keys must be limited to :a/:b/:c/:d" unless (weighted_values.keys - %i[a b c d]).empty?

    @weighted_values = weighted_values
  end

  # Generate the tsvector value through a Postgres query
  def tsvector
    @tsvector ||= ActiveRecord::Base.connection.execute(query.to_sql).first.values.first
  end

  private

  attr_reader :vacancy, :weighted_values

  def query
    Arel::SelectManager.new.project(build_weighted_document_query(weighted_values))
  end

  def build_weighted_document_query(weight_to_values_hash)
    nodes = weight_to_values_hash.flat_map do |weight, values|
      # Add a blank space after individual weighted vectors so they don't stick together
      [setweight(to_tsvector(values), weight), Arel::Nodes::Quoted.new(" ")]
    end

    Arel::Nodes::NamedFunction.new("CONCAT", nodes)
  end

  def setweight(tsvector_node, weight)
    Arel::Nodes::NamedFunction.new(
      "setweight",
      [tsvector_node, Arel::Nodes::Quoted.new(weight.upcase)],
    )
  end

  def to_tsvector(*value_or_values)
    document = Array(value_or_values).join(" ")

    Arel::Nodes::NamedFunction.new(
      "to_tsvector",
      [Arel::Nodes::Quoted.new("simple"), Arel::Nodes::Quoted.new(document)],
    )
  end
end
