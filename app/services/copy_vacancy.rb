class CopyVacancy
  def initialize(vacancy)
    @vacancy = vacancy
    setup_new_vacancy
  end

  def call
    @new_vacancy.send(:set_slug)
    @new_vacancy.save(validate: false)
    copy_documents
    @new_vacancy
  end

  private

  def copy_documents
    @vacancy.supporting_documents.each do |supporting_doc|
      @new_vacancy.supporting_documents.attach(supporting_doc.blob)
    end
  end

  def setup_new_vacancy
    @new_vacancy = @vacancy.dup
    @new_vacancy.status = :draft
    reset_date_fields if @vacancy.publish_on&.past?
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

  def current_steps
    Publishers::Vacancies::VacancyStepProcess.new(:job_role,
                                                  vacancy: @vacancy,
                                                  organisation: @vacancy.organisation).steps
  end
end
