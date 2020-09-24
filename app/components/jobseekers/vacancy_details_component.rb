class Jobseekers::VacancyDetailsComponent < ViewComponent::Base
  attr_accessor :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
  end

  def rows
    [{ present: vacancy.job_roles&.any?, th: I18n.t('jobs.job_roles'), td: vacancy.show_job_roles },
     { present: vacancy.subjects&.any?,
       th: I18n.t('jobs.subject', count: vacancy.subjects&.count),
       td: vacancy.show_subjects },
     { present: true, th: I18n.t('jobs.working_patterns'), td: vacancy.working_patterns },
     { present: true, th: I18n.t('jobs.salary'), td: vacancy.salary }]
  end
end
