class Search::SimilarJobs
  attr_reader :similar_jobs

  NUMBER_OF_SIMILAR_JOBS = 4

  def initialize(vacancy)
    # For now, similar jobs are retrieved based on the same set of rules that define similar job alerts
    criteria = Search::CriteriaDeviser.new(vacancy).criteria
    @similar_jobs = Search::SearchBuilder.new(criteria).vacancies.reject { |job| job.id == vacancy.id }.take(NUMBER_OF_SIMILAR_JOBS)
  end
end
