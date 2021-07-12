module PgSearchable
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model

    before_save :update_searchable

    pg_search_scope :pg_search,
                    against: :searchable,
                    using: {
                      tsearch: {
                        negation: true,
                        tsvector_column: :searchable,
                      },
                    }

    private

    def update_searchable
      to_tsvector = concat([
        setweight([job_title], "A"),
        Arel::Nodes::Quoted.new(" "),
        setweight(subjects, "B"),
      ])

      self.searchable =
        ActiveRecord::Base
          .connection
          .execute(Arel::SelectManager.new.project(to_tsvector).to_sql)
          .first
          .values
          .first
    end

    def concat(ts_vectors)
      Arel::Nodes::NamedFunction.new(
        "CONCAT",
        ts_vectors,
      )
    end

    def setweight(values, weight)
      Arel::Nodes::NamedFunction.new(
        "SETWEIGHT",
        [
          to_tsvector(values),
          Arel::Nodes::Quoted.new(weight),
        ],
      )
    end

    def to_tsvector(values)
      Arel::Nodes::NamedFunction.new(
        "TO_TSVECTOR", [
          Arel::Nodes::Quoted.new("pg_catalog.simple"),
          Arel::Nodes::Quoted.new(values.join(" ")),
        ]
      )
    end
  end
end
