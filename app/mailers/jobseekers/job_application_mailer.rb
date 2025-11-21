module Jobseekers
  class JobApplicationMailer < BaseMailer
    # rubocop isn't very good at counting lines of code sometimes...
    # rubocop:disable Metrics/MethodLength
    def application_submitted(job_application)
      vacancy = job_application.vacancy

      if vacancy.teaching_or_middle_leader_role?
        template_mail("0a75c46b-923f-4ee0-807c-99fd289a881a",
                      to: job_application.email_address,
                      personalisation: {
                        job_title: vacancy.job_title,
                        organisation_name: vacancy.organisation_name,
                        contact_email: vacancy.contact_email,
                        job_application_link: Rails.application.routes.url_helpers.jobseekers_job_applications_url,
                        teaching_job_interview_link: Rails.application.routes.url_helpers.jobseeker_guides_how_to_approach_a_teaching_job_interview_url,
                        teaching_interview_lesson_link: Rails.application.routes.url_helpers.jobseeker_guides_prepare_for_a_teaching_job_interview_lesson_url,
                      })
      else
        template_mail("76fabced-ca9c-4ebb-8c57-58f970124fa9",
                      to: job_application.email_address,
                      personalisation: {
                        job_title: vacancy.job_title,
                        organisation_name: vacancy.organisation_name,
                        contact_email: vacancy.contact_email,
                        job_application_link: Rails.application.routes.url_helpers.jobseekers_job_applications_url,
                      })
      end
    end
    # rubocop:enable Metrics/MethodLength

    def job_listing_ended_early(job_application, vacancy)
      @job_application = job_application
      @jobseeker = job_application.jobseeker
      @vacancy = vacancy

      send_email(to: @jobseeker.email, subject: t(".subject", job_title: @vacancy.job_title, organisation_name: @vacancy.organisation_name))
    end

    def self_disclosure(job_application)
      @job_application = job_application
      @vacancy = @job_application.vacancy
      @organisation_name = @vacancy.organisation_name

      send_email(to: job_application.email_address, subject: t(".subject", job_title: @vacancy.job_title, organisation_name: @vacancy.organisation_name))
    end
  end
end
