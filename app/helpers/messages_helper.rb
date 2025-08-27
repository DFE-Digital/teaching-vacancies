module MessagesHelper
  def message_sender_display_name(message, job_application, vacancy)
    if message.sender_type == "Publisher"
      publisher_message_display_name(message, vacancy)
    else
      jobseeker_message_display_name(message, job_application)
    end
  end

  def publisher_message_display_name(message, vacancy)
    "#{message.sender.given_name} #{message.sender.family_name}, #{vacancy.organisation_name} <via Teaching Vacancies>"
  end

  def jobseeker_message_display_name(message, job_application)
    "#{job_application.name} <#{message.sender.email}>"
  end

  def message_card_title_class(message, current_user)
    message.sender == current_user ? "message-header--blue" : "message-header--grey"
  end
end
