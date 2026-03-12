class CopyVacancyAsaTemplate
  IGNORED_ATTRIBUTES = %w[
    id
    job_title
    slug
    job_advert
    starts_on
    publish_on
    application_link
    listed_elsewhere
    hired_status
    stats_updated_at
    publisher_id
    expires_at
    about_school
    job_location
    readable_job_location
    publisher_organisation_id
    starts_asap
    completed_steps
    geolocation
    readable_phases
    searchable_content
    google_index_removed
    expired_vacancy_feedback_email_sent_at
    external_source
    external_reference
    external_advert_url
    start_date_type
    earliest_start_date
    latest_start_date
    other_start_date_details
    contact_number_provided
    extension_reason
    other_extension_reason_details
    publisher_ats_api_client_id
    discarded_at
    type
    uk_geolocation
  ].freeze

  # don't call this code directly - it needs to send analytics events
  # via a controller
  class << self
    def call(vacancy, name)
      new_template = VacancyTemplate.new(vacancy.attributes
                                                .except(*(IGNORED_ATTRIBUTES + %w[job_roles]))
                                                .merge(name: name, job_roles: vacancy.job_roles))
      # new_template.application_form.attach(vacancy.application_form.blob) if vacancy.application_form.attachments&.any?

      # if vacancy.supporting_documents.attachments.any?
      #   vacancy.supporting_documents.each { |supporting_document| new_template.supporting_documents.attach(supporting_document.blob) }
      #
      #   new_template.include_additional_documents = true
      #   # new_template.completed_steps = completed_steps(vacancy)
      # else
      new_template.include_additional_documents = nil
      # new_template.completed_steps = completed_steps(vacancy) - %w[documents]
      new_template.tap(&:save!)
    end
    # def completed_steps(vacancy)
    #   process = Publishers::Vacancies::VacancyStepProcess.new(:review,
    #                                                           vacancy: vacancy,
    #                                                           organisation: vacancy.organisation)
    #   (process.steps - [:review]).select do |step_name|
    #     step_form_class = File.join("publishers/job_listing", "#{step_name}_form").camelize.constantize
    #
    #     step_form_class.load_from_model(vacancy, current_publisher: nil).valid?
    #   end
    # end
  end
end
