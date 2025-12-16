module Jobseekers
  class JobApplicationMailer < BaseMailer
    def application_submitted(job_application)
      vacancy = job_application.vacancy

      if vacancy.teaching_or_middle_leader_role?
        submitted_teaching(job_application.email_address, vacancy)
      else
        submitted_non_teaching(job_application.email_address, vacancy)
      end
    end

    def job_listing_ended_early(job_application, vacancy)
      template_mail("70402cf4-5ef2-4549-a4c2-571766f5b7df",
                    to: job_application.jobseeker.email,
                    personalisation: {
                      job_title: vacancy.job_title,
                      organisation_name: vacancy.organisation_name,
                      link: jobseekers_job_application_url(job_application),
                      home_page_link: root_url,
                    })
    end

    def self_disclosure(job_application)
      vacancy = job_application.vacancy

      template_mail("b58b133b-bba8-43c9-9642-72f0aea19837",
                    to: job_application.email_address,
                    personalisation: {
                      name: job_application.name,
                      job_title: vacancy.job_title,
                      organisation_name: vacancy.organisation_name,
                      link: jobseekers_job_application_self_disclosure_url(job_application, Wicked::FIRST_STEP),
                    })
    end

    private

    def submitted_teaching(email, vacancy)
      template_mail("0a75c46b-923f-4ee0-807c-99fd289a881a",
                    to: email,
                    personalisation: {
                      home_page_link: root_url,
                      job_title: vacancy.job_title,
                      organisation_name: vacancy.organisation_name,
                      contact_email: vacancy.contact_email,
                      job_application_link: jobseekers_job_applications_url,
                      teaching_job_interview_link: jobseeker_guides_how_to_approach_a_teaching_job_interview_url,
                      teaching_interview_lesson_link: jobseeker_guides_prepare_for_a_teaching_job_interview_lesson_url,
                    })
    end

    def submitted_non_teaching(email, vacancy)
      template_mail("76fabced-ca9c-4ebb-8c57-58f970124fa9",
                    to: email,
                    personalisation: {
                      home_page_link: root_url,
                      job_title: vacancy.job_title,
                      organisation_name: vacancy.organisation_name,
                      contact_email: vacancy.contact_email,
                      job_application_link: jobseekers_job_applications_url,
                    })
    end
  end
end
