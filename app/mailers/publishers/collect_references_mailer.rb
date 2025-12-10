# frozen_string_literal: true

module Publishers
  class CollectReferencesMailer < BaseMailer
    def collect_references(reference_request)
      job_application = reference_request.referee.job_application

      template_mail("38645d98-25b1-4eee-a2e8-69b932b6f5a0",
                    to: reference_request.referee.email,
                    personalisation: {
                      referee_name: reference_request.referee.name,
                      candidate_name: job_application.name,
                      job_title: job_application.vacancy.job_title,
                      organisation_name: job_application.vacancy.organisation_name,
                      # Wicked::Wizard redirects to first step w/o any parameters so we have to mention first step here explcitly
                      link: reference_build_url(reference_request.id, "can_give", token: reference_request.token),
                      school_email: job_application.vacancy.contact_email,
                      home_page_link: root_url,
                    })
    end

    def inform_applicant_about_references(job_application)
      @job_application = job_application
      @job_title = job_application.vacancy.job_title
      @organisation_name = job_application.vacancy.organisation_name
      send_email(to: job_application.email_address, subject: t(".subject",
                                                               job_title: @job_title,
                                                               organisation_name: @organisation_name))
    end

    def self_disclosure_received(job_application)
      template_mail("c08269dd-c2d1-4007-a119-f45105e329c9",
                    to: job_application.vacancy.publisher.email,
                    personalisation: {
                      name: job_application.vacancy.publisher.papertrail_display_name,
                      candidate_name: job_application.name,
                      job_title: job_application.vacancy.job_title,
                      organisation_name: job_application.vacancy.organisation_name,
                      link: organisation_job_job_application_self_disclosure_url(job_application.vacancy.id, job_application),
                      home_page_link: root_url,
                    })
    end

    def reference_received(reference_request)
      job_application = reference_request.referee.job_application

      template_mail("bc0a44f5-d8d3-44d3-b18d-10b99f61be16",
                    to: job_application.vacancy.publisher.email,
                    personalisation: {
                      name: job_application.vacancy.publisher.papertrail_display_name,
                      candidate_name: job_application.name,
                      job_title: job_application.vacancy.job_title,
                      organisation_name: job_application.vacancy.organisation_name,
                      link: organisation_job_job_application_reference_request_url(job_application.vacancy.id, job_application, reference_request),
                      home_page_link: root_url,
                    })
    end
  end
end
