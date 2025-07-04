# frozen_string_literal: true

module Publishers
  class CollectReferencesMailer < BaseMailer
    def collect_references(reference_request)
      @reference_request = reference_request
      job_application = reference_request.referee.job_application
      send_email(to: reference_request.referee.email, subject: t(".subject", name: job_application.name,
                                                                             job_title: job_application.vacancy.job_title,
                                                                             organisation_name: job_application.vacancy.organisation_name))
    end

    def inform_applicant_about_references(job_application)
      @name = job_application.name
      @job_title = job_application.vacancy.job_title
      @organisation_name = job_application.vacancy.organisation_name
      send_email(to: job_application.email_address, subject: t(".subject",
                                                               job_title: @job_title,
                                                               organisation_name: @organisation_name))
    end
  end
end
