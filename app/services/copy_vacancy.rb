class CopyVacancy
  def initialize(vacancy:)
    @vacancy = vacancy
  end

  def copy
    @vacancy_copy = @vacancy.dup
    update_fields
    @vacancy_copy
  end

  private

  def update_fields
    @vacancy_copy.job_title = "#{I18n.t('jobs.copy_of')} #{@vacancy.job_title}"
    @vacancy_copy.status = :draft
    @vacancy_copy.publish_on = Time.zone.today if @vacancy_copy.publish_on <= Time.zone.today
  end
end
