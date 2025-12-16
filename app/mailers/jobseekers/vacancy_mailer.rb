module Jobseekers
  class VacancyMailer < BaseMailer
    def draft_application_only(job_application)
      template_mail("6e00f96f-28ee-4217-a0d7-f70c5416f0ea",
                    to: job_application.jobseeker.email,
                    personalisation: {
                      date: job_application.vacancy.expires_at.to_date.to_fs,
                      job_title: job_application.vacancy.job_title,
                      school: job_application.vacancy.organisation.name,
                      application_link: jobseekers_job_application_review_url(job_application),
                      advice_link: jobseeker_guides_write_a_great_teaching_job_application_in_five_steps_url,
                      home_page_link: root_url,
                    })
    end

    def unapplied_saved_vacancy(vacancy, jobseeker)
      template_mail("d8c2bc60-d024-4e40-80b3-7d3e8c9cf96d",
                    to: jobseeker.email,
                    personalisation: {
                      date: vacancy.expires_at.to_date.to_fs,
                      job_title: vacancy.job_title,
                      first_name: jobseeker.jobseeker_profile&.first_name,
                      school: vacancy.organisation.name,
                      apply_for_link: job_url(vacancy),
                      advice_link: jobseeker_guides_write_a_great_teaching_job_application_in_five_steps_url,
                      home_page_link: root_url,
                    })
    end
  end
end
