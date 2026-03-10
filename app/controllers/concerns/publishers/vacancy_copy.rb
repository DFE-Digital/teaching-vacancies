# frozen_string_literal: true

module Publishers
  module VacancyCopy
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
      contact_email
      application_email
      contact_number
      parental_leave_cover_contract_duration
      include_additional_documents
    ].freeze

    # This should be used so that analytics can be sent after
    # a vacancy is duplicated (effectively treating the original as a template)

    def copy_vacancy(vacancy, name)
      VacancyTemplate.create!(
        vacancy.attributes
               .except(*(IGNORED_ATTRIBUTES + %w[job_roles key_stages phases working_patterns]))
               .merge(name: name, job_roles: vacancy.job_roles,
                      phases: vacancy.phases,
                      working_patterns: vacancy.working_patterns,
                      key_stages: vacancy.key_stages),
      )

      # CopyVacancyAsaTemplate.call(vacancy, name).tap do |new_vacancy|
      #   if new_vacancy.include_additional_documents
      #     new_vacancy.supporting_documents.attachments.each do |document|
      #       send_dfe_analytics_event(:supporting_document_created, new_vacancy.id, document.blob)
      #     end
      #   end
      # end
    end

    def send_dfe_analytics_event(event_type, vacancy_id, blob)
      fail_safe do
        event = DfE::Analytics::Event.new
                                     .with_type(event_type)
                                     .with_request_details(request)
                                     .with_response_details(response)
                                     .with_user(current_publisher)
                  # if new_vacancy.application_form.present?
                  #   send_dfe_analytics_event(:supporting_document_created, new_vacancy.id, new_vacancy.application_form.attachment.blob)
                  # end
                  .with_data(data: {
                    vacancy_id: vacancy_id,
                    document_type: "supporting_document",
                    name: blob.filename,
                    size: blob.byte_size,
                    content_type: blob.content_type,
                  })

        DfE::Analytics::SendEvents.do([event])
      end
    end
  end
end
