module Jobseekers
  class MessageMailer < BaseMailer
    def message_received(message)
      template_mail("63c648e9-5bc2-4ad8-911c-435eb49a0624",
                    to: message.conversation.job_application.jobseeker.email,
                    personalisation: {
                      organisation_name: message.conversation.job_application.vacancy.organisation.name,
                      job_title: message.conversation.job_application.vacancy.job_title,
                      first_name: message.conversation.job_application.first_name,
                      sign_in_link: new_jobseeker_session_url,
                      home_page_link: root_url,
                    })
    end

    def rejection_message(message)
      template_mail("77b836d4-6609-4b63-ab67-fb97e400b1d2",
                    to: message.conversation.job_application.jobseeker.email,
                    personalisation: {
                      organisation_name: message.conversation.job_application.vacancy.organisation.name,
                      job_title: message.conversation.job_application.vacancy.job_title,
                      first_name: message.conversation.job_application.first_name,
                      sign_in_link: new_jobseeker_session_url,
                      home_page_link: root_url,
                    })
    end
  end
end
