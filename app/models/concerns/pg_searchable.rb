module PgSearchable
  extend ActiveSupport::Concern

  # Question: should we reindex if associated model changes?

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

    scope :pg_raw_search, lambda { |dangerous_query|
      builder = Search::KeywordQueryBuilder.new(dangerous_query)
      where("searchable @@ (#{builder.to_search_query})").order(builder.to_ranking)
    }

    private

    def update_searchable # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      to_tsvector = concat([
        setweight([
          job_title,
        ], "A"),
        Arel::Nodes::Quoted.new(" "),
        setweight([
          subjects,
          education_phases,
          VacancyPresenter.new(self).show_job_roles,
          parent_organisation_name,
          VacancyPresenter.new(self).working_patterns,
        ], "B"),
        Arel::Nodes::Quoted.new(" "),
        setweight([
          organisations.map(&:name),
          organisations.map(&:county).uniq,
          organisations.schools.map(&:detailed_school_type).uniq,
          organisations.school_groups.map(&:group_type).reject(&:blank?).uniq,
          organisations.map(&:local_authority_within).reject(&:blank?).uniq,
          organisations.schools.map(&:religious_character).reject(&:blank?).uniq,
          organisations.schools.map(&:region).uniq,
          organisations.schools.map { |org| org.school_type&.singularize }.uniq,
          organisations.map(&:town).reject(&:blank?).uniq,
        ], "C"),
        # Arel::Nodes::Quoted.new(" "),
        # setweight([
        #   strip_tags(job_advert)&.truncate(256),
        # ], "D"),
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
          Arel::Nodes::Quoted.new(values.flatten.join(" ")),
        ]
      )
    end
  end
end
