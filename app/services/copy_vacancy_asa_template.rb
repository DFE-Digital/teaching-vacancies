class CopyVacancyAsaTemplate
  # don't call this code directly - it needs to send analytics events
  # via a controller
  class << self
    def call(vacancy)
      new_vacancy = vacancy.dup
      new_vacancy.status = :draft
      new_vacancy.application_form.attach(vacancy.application_form.blob) if vacancy.application_form.attachments&.any?

      if vacancy.supporting_documents.attachments.any?
        vacancy.supporting_documents.each { |supporting_document| new_vacancy.supporting_documents.attach(supporting_document.blob) }

        new_vacancy.include_additional_documents = true
      else
        new_vacancy.include_additional_documents = nil
      end

      # :nocov:
      reset_date_fields(new_vacancy) if vacancy.publish_on&.past?
      # :nocov:

      reset_legacy_fields(new_vacancy)
      new_vacancy.completed_steps = current_steps(vacancy)
      new_vacancy.organisations = vacancy.organisations
      new_vacancy.send(:set_slug)
      new_vacancy.save(validate: false)
      new_vacancy
    end

    private

    def reset_date_fields(new_vacancy)
      new_vacancy.expires_at = nil
      new_vacancy.start_date_type = nil
      new_vacancy.starts_on = nil
      new_vacancy.earliest_start_date = nil
      new_vacancy.latest_start_date = nil
      new_vacancy.other_start_date_details = nil
      new_vacancy.publish_on = nil
    end

    def reset_legacy_fields(new_vacancy)
      new_vacancy.job_advert = nil
      new_vacancy.about_school = nil
      new_vacancy.personal_statement_guidance = nil
      new_vacancy.school_visits_details = nil
      new_vacancy.how_to_apply = nil
      new_vacancy.safeguarding_information_provided = nil
      new_vacancy.safeguarding_information = nil
    end

    def current_steps(vacancy)
      Publishers::Vacancies::VacancyStepProcess.new(:job_role,
                                                    vacancy: vacancy,
                                                    organisation: vacancy.organisation).steps
    end
  end
end
