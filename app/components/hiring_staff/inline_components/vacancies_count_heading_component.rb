class HiringStaff::InlineComponents::VacanciesCountHeadingComponent < ViewComponent::Base
  def initialize(vacancies: vacancies, selected_type: selected_type)
    @vacancies = vacancies
    @selected_type = selected_type
  end

  def call
    t("jobs.#{@selected_type}_jobs_with_count",
      count: @vacancies.count,
      jobs: @vacancies.count == 1 ? t('jobs.job') : t('jobs.job').pluralize)
  end
end
