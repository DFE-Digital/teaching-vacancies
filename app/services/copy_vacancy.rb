class CopyVacancy
  def initialize(vacancy)
    @vacancy = vacancy
    setup_new_vacancy
  end

  def call
    @new_vacancy.send(:set_slug)
    @new_vacancy.save(validate: false)
    @new_vacancy
  end

  private

  def setup_new_vacancy
    @new_vacancy = @vacancy.dup
    @new_vacancy.status = :draft
    reset_date_fields if @vacancy.publish_on&.past?
    reset_legacy_fields
    @new_vacancy.completed_steps = current_steps
    @new_vacancy.organisations = @vacancy.organisations
  end

  def reset_date_fields
    @new_vacancy.expires_at = nil
    @new_vacancy.start_date_type = nil
    @new_vacancy.starts_on = nil
    @new_vacancy.earliest_start_date = nil
    @new_vacancy.latest_start_date = nil
    @new_vacancy.other_start_date_details = nil
    @new_vacancy.publish_on = nil
  end

  def reset_legacy_fields
    @new_vacancy.job_advert = nil
    @new_vacancy.about_school = nil
    @new_vacancy.personal_statement_guidance = nil
    @new_vacancy.school_visits_details = nil
    @new_vacancy.how_to_apply = nil
  end

  def current_steps
    Publishers::Vacancies::VacancyStepProcess.new(:job_role,
                                                  vacancy: @vacancy,
                                                  organisation: @vacancy.organisation).steps
  end
end
