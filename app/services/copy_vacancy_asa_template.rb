class CopyVacancyAsaTemplate
  # don't call this code directly - it needs to send analytics events
  # via a controller
  class << self
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def call(vacancy)
      new_vacancy = vacancy.dup
      new_vacancy.type = "DraftVacancy"
      new_vacancy.application_form.attach(vacancy.application_form.blob) if vacancy.application_form.attachments&.any?

      if vacancy.supporting_documents.attachments.any?
        vacancy.supporting_documents.each { |supporting_document| new_vacancy.supporting_documents.attach(supporting_document.blob) }

        new_vacancy.include_additional_documents = true
        new_vacancy.completed_steps = current_steps(vacancy)
      else
        new_vacancy.include_additional_documents = nil
        new_vacancy.completed_steps = current_steps(vacancy) - [:documents]
      end

      # :nocov:
      if vacancy.publish_on&.past?
        reset_date_fields(new_vacancy)
        new_vacancy.completed_steps -= %i[start_date important_dates]
      end
      # :nocov:

      reset_legacy_fields(new_vacancy)
      new_vacancy.organisations = vacancy.organisations
      new_vacancy.send(:set_slug)
      new_vacancy.save!(validate: false)
      new_vacancy
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    private

    def reset_date_fields(new_vacancy)
      new_vacancy.assign_attributes(expires_at: nil, start_date_type: nil, starts_on: nil,
                                    earliest_start_date: nil, latest_start_date: nil, other_start_date_details: nil, publish_on: nil)
    end

    def reset_legacy_fields(new_vacancy)
      new_vacancy.safeguarding_information_provided = nil
      new_vacancy.safeguarding_information = nil
    end

    def current_steps(vacancy)
      process = Publishers::Vacancies::VacancyStepProcess.new(:job_role,
                                                              vacancy: vacancy,
                                                              organisation: vacancy.organisation)
      Publishers::VacancyFormSequence.new(vacancy: vacancy, organisation: vacancy.organisation, step_process: process).valid_steps
    end
  end
end
