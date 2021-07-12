module PgSearchable
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model

    pg_search_scope :pg_search,
                    against: %i[job_title subjects]
  end
end
