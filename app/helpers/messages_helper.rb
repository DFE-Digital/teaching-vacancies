module MessagesHelper
  def publisher_message_display_name(message, vacancy)
    "#{message.sender.given_name} #{message.sender.family_name}, #{vacancy.organisation_name} <via Teaching Vacancies> #{message.created_at.to_fs(:date_at_time)}"
  end

  def jobseeker_message_display_name(message, job_application)
    "#{job_application.name} <#{job_application.email_address}> #{message.created_at.to_fs(:date_at_time)}"
  end

  def jobseeker_message_card_title_class(message, current_user)
    message.sender == current_user ? "message-header--sender" : "message-header--recipient"
  end

  def publisher_message_card_title_class(message, job_application)
    message.sender == job_application.jobseeker ? "message-header--recipient" : "message-header--sender"
  end
end
