class Search::ReplicaBuilder
  attr_reader :search_replica

  def initialize(job_sort, keyword)
    # A blank `sort_by` results in a search on the base index, Indexable::INDEX_NAME
    sort_by = if job_sort.blank? || !valid_sort?(job_sort)
                keyword.blank? ? "publish_on_desc" : ""
              else
                job_sort
              end
    @search_replica = [Indexable::INDEX_NAME, sort_by].reject(&:blank?).join("_") if sort_by.present?
  end

  private

  def valid_sort?(sort)
    Vacancy::JOB_SORTING_OPTIONS.map(&:last).include?(sort)
  end
end
