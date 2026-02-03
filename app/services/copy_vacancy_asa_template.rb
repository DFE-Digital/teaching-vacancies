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
        new_vacancy.completed_steps = completed_steps(vacancy)
      else
        new_vacancy.include_additional_documents = nil
        new_vacancy.completed_steps = completed_steps(vacancy) - %w[documents]
      end

      # convert legacy email vacancies into uploaded ones
      new_vacancy.receive_applications = :uploaded_form if vacancy.email?

      if vacancy.publish_on&.past?
        reset_date_fields(new_vacancy)
        new_vacancy.completed_steps -= %w[start_date important_dates]
      end

      new_vacancy.tap do |v|
        v.organisations = vacancy.organisations
        v.send(:set_slug)
        v.save!(validate: false)
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    private

    def reset_date_fields(new_vacancy)
      new_vacancy.assign_attributes(expires_at: nil, start_date_type: nil, starts_on: nil,
                                    earliest_start_date: nil, latest_start_date: nil, other_start_date_details: nil, publish_on: nil)
    end

    def completed_steps(vacancy)
      process = Publishers::Vacancies::VacancyStepProcess.new(:review,
                                                              vacancy: vacancy,
                                                              organisation: vacancy.organisation)
      (process.steps - [:review]).select do |step_name|
        step_form_class = File.join("publishers/job_listing", "#{step_name}_form").camelize.constantize

        params = step_form_class.load_form(vacancy)

        step_form_class.new(params, vacancy).valid?
      end
    end
  end
end
