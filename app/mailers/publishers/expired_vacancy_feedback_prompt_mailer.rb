module Publishers
  class ExpiredVacancyFeedbackPromptMailer < BaseMailer
    def prompt_for_feedback(publisher, vacancy)
      template_mail("1f48808e-5e07-45be-84a4-1488dceb4ae1",
                    to: publisher.email,
                    personalisation: {
                      job_title: vacancy.job_title,
                      expired_vacancy_feedback_link: new_organisation_job_expired_feedback_url(vacancy.signed_id),
                      expired_vacancy_unsubscribe_link: confirm_unsubscribe_publishers_account_url(publisher_id: publisher.signed_id),
                    })
    end
  end
end
