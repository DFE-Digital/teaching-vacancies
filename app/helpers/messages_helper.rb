module MessagesHelper
  def sender_is_current_user?(message, current_user_type)
    (current_user_type == "jobseeker" && message.sender_type == "Jobseeker") ||
      (current_user_type == "publisher" && message.sender_type == "Publisher")
  end

  def message_sender_display_name(message, job_application, vacancy)
    if message.sender_type == "Publisher"
      "#{message.sender.given_name} #{message.sender.family_name}, #{vacancy.organisation_name} <via Teaching Vacancies>"
    else
      "#{job_application.name} <#{message.sender.email}>"
    end
  end

  def message_card_title_class(message, current_user_type)
    sender_is_current_user?(message, current_user_type) ? "message-header--jobseeker" : "message-header--staff"
  end
end
