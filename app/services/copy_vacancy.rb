class CopyVacancy
  def initialize(vacancy, klass = DraftVacancy)
    @vacancy = vacancy
    setup_new_vacancy klass
  end

  def call
    @new_vacancy.send(:set_slug)
    @new_vacancy.save(validate: false)
    @new_vacancy
  end

  private

  def setup_new_vacancy klass
    attributes = @vacancy.dup.attributes.symbolize_keys.except(:id, :type, :slug, :status, :created_at, :updated_at).keys.index_with { |attribute|
      @vacancy.public_send(attribute)
    }
    @new_vacancy = klass.new(attributes)
    copy_application_form if @vacancy.application_form.attachments&.any?

    if @vacancy.supporting_documents.attachments&.any?
      copy_supporting_documents
    else
      @new_vacancy.include_additional_documents = nil
    end

    reset_date_fields if @vacancy.publish_on&.past?
    reset_legacy_fields
    @new_vacancy.completed_steps = current_steps
    @new_vacancy.organisations = @vacancy.organisations
  end

  def copy_application_form
    @new_vacancy.application_form.attach(@vacancy.application_form.blob)
  end

  def copy_supporting_documents
    @vacancy.supporting_documents.each { |supporting_document| @new_vacancy.supporting_documents.attach(supporting_document.blob) }

    @new_vacancy.include_additional_documents = true
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
    @new_vacancy.safeguarding_information_provided = nil
    @new_vacancy.safeguarding_information = nil
  end

  def current_steps
    Publishers::Vacancies::VacancyStepProcess.new(:job_role,
                                                  vacancy: @vacancy,
                                                  organisation: @vacancy.organisation).steps
  end
end
