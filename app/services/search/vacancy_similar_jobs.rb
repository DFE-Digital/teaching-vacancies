class Search::VacancySimilarJobs
  attr_reader :similar_jobs

  NUMBER_OF_SIMILAR_JOBS = 4

  def initialize(vacancy)
    # For now, similar jobs are retrived based on the same set of rules that define similar job alerts
    criteria = Search::CriteriaDeviser.new(vacancy).criteria
    similar_jobs_search = Search::VacancySearchBuilder.new(criteria).call
    @similar_jobs = similar_jobs_search.vacancies.reject { |job| job.id == vacancy.id }.take(NUMBER_OF_SIMILAR_JOBS)
  end
end
