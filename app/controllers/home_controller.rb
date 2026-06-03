class HomeController < ApplicationController
  VacancyCounts = Data.define(:role_counts, :phase_counts, :working_pattern_counts, :subjects_counts)

  def index
    @form = Jobseekers::SearchForm.new
    school_scope = PublishedVacancy.live.in_organisation_ids(Organisation.in_scope_schools.pluck(:id))
    @school_counts = VacancyCounts.new(
      role_counts: VacancyCounter.role_counts(scope: school_scope),
      phase_counts: VacancyCounter.phase_counts(scope: school_scope),
      working_pattern_counts: VacancyCounter.working_pattern_counts(scope: school_scope),
      subjects_counts: VacancyCounter.subject_counts(scope: school_scope),
    )
    fe_scope = PublishedVacancy.live.in_organisation_ids(Organisation.colleges.pluck(:id))
    @fe_counts = VacancyCounts.new(
      role_counts: VacancyCounter.role_counts(scope: fe_scope),
      phase_counts: VacancyCounter.phase_counts(scope: fe_scope),
      working_pattern_counts: VacancyCounter.working_pattern_counts(scope: fe_scope),
      subjects_counts: VacancyCounter.subject_counts(scope: fe_scope),
    )
  end

  private

  def set_headers
    response.set_header("X-Robots-Tag", "index, nofollow")
  end
end
