# frozen_string_literal: true

module Publishers
  class CollectReferencesMailer < BaseMailer
    def collect_references(reference_request)
      @reference_request = reference_request
      @job_application = reference_request.referee.job_application
      send_email(to: reference_request.referee.email,
                 subject: t(".subject", name: @job_application.name,
                                        job_title: @job_application.vacancy.job_title,
                                        organisation_name: @job_application.vacancy.organisation_name))
    end

    def inform_applicant_about_references(job_application)
      template_mail("4a85ba4d-2033-47a5-8f64-101479778ba2",
                    to: job_application.email_address,
                    personalisation: {
                      name: job_application.name,
                      job_title: job_application.vacancy.job_title,
                      organisation_name: job_application.vacancy.organisation_name,
                      link: jobseekers_job_application_url(job_application, anchor: "referees"),
                      home_page_link: root_url,
                    })
    end

    def self_disclosure_received(job_application)
      @job_application = job_application

      send_email(to: job_application.vacancy.publisher.email,
                 subject: t(".subject", organisation_name: job_application.vacancy.organisation.name,
                                        job_title: job_application.vacancy.job_title))
    end

    def reference_received(reference_request)
      @reference_request = reference_request
      @job_application = reference_request.referee.job_application

      send_email(to: @job_application.vacancy.publisher.email,
                 subject: t(".subject",
                            organisation_name: @job_application.vacancy.organisation.name,
                            candidate_name: @job_application.name,
                            job_title: @job_application.vacancy.job_title))
    end
  end
end
