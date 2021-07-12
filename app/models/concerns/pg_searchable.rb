module PgSearchable
  extend ActiveSupport::Concern

  included do
    include ::PgSearch::Model

    include ActionView::Helpers::SanitizeHelper

    before_save :set_searchable

    pg_search_scope :pg_search,
                    against: %i[searchable],
                    using: {
                      tsearch: {
                        prefix: true,
                        dictionary: "english",
                        tsvector_column: "searchable",
                      },
                    }

    def set_searchable # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      set_vector_column(
        :searchable,
        {
          A: [
            job_title,
            subjects,
          ],
          B: [
            education_phases,
            job_roles,
            parent_organisation_name,
            VacancyPresenter.new(self).working_patterns,
          ],
          C: [
            organisations.map(&:name),
            organisations.map(&:county).uniq,
            organisations.schools.map(&:detailed_school_type).uniq,
            organisations.school_groups.map(&:group_type).reject(&:blank?).uniq,
            organisations.map(&:local_authority_within).reject(&:blank?).uniq,
            organisations.schools.map(&:religious_character).reject(&:blank?).uniq,
            organisations.schools.map(&:region).uniq,
            organisations.schools.map { |org| org.school_type&.singularize }.uniq,
            organisations.map(&:town).reject(&:blank?).uniq,
          ],
          D: [
            strip_tags(job_advert)&.truncate(256),
          ],
        },
      )
    end

    private

    def set_vector_column(column, values)
      query = concat(values.map { |weight, vals| setweight(weight, vals) })

      attributes[column] = ActiveRecord::Base
        .connection
        .execute(Arel::SelectManager.new.project(query).to_sql)
        .first
        .values
        .first
    end

    def concat(queries)
      Arel::Nodes::NamedFunction.new("CONCAT", queries)
    end

    def setweight(weight, values)
      Arel::Nodes::NamedFunction.new(
        "SETWEIGHT", [
          to_tsvector(values),
          Arel::Nodes::Quoted.new(weight),
        ]
      )
    end

    def to_tsvector(values)
      ts_vector_value = values.flatten.reject(&:blank?).join(" ")

      Arel::Nodes::NamedFunction.new(
        "TO_TSVECTOR", [
          Arel::Nodes::Quoted.new("english"),
          Arel::Nodes::Quoted.new(ts_vector_value),
        ]
      )
    end
  end
end
