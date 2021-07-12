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
      ts_vector_value = [job_title, *subjects].join(" ")

      to_tsvector = Arel::Nodes::NamedFunction.new(
        "TO_TSVECTOR", [
          Arel::Nodes::Quoted.new("pg_catalog.simple"),
          Arel::Nodes::Quoted.new(ts_vector_value),
        ]
      )

      self.searchable =
        ActiveRecord::Base
          .connection
          .execute(Arel::SelectManager.new.project(to_tsvector).to_sql)
          .first
          .values
          .first
    end
  end
end
