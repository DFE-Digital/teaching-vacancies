class Search::SimilarJobs
  attr_reader :vacancy

  NUMBER_OF_SIMILAR_JOBS = 4
  CACHE_DURATION = 12.hours

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def criteria
    # For now, similar jobs are retrieved based on the same set of rules that define similar job alerts
    @criteria ||= Search::CriteriaInventor.new(vacancy).criteria
  end

  def similar_jobs
    @similar_jobs ||= Vacancy.live.where(id: similar_job_ids).first(NUMBER_OF_SIMILAR_JOBS)
  end

  private

  def similar_job_ids
    Rails.cache.fetch([:similar_job_ids, vacancy.id], expires_in: CACHE_DURATION) do
      Search::VacancySearch
        .new(criteria)
        .vacancies
        .limit(NUMBER_OF_SIMILAR_JOBS * 3) # Fetch more than we need in case some expire while being cached
        .reject { |job| job.id == vacancy.id }
        .map(&:id)
    end
  end
end
