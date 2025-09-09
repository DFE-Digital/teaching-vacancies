module MessagingHelper
  def can_jobseeker_send_message?(job_application)
    if job_application.conversations.any?
      can_jobseeker_reply_to_message?(job_application)
    else
      can_jobseeker_initiate_message?(job_application)
    end
  end

  def can_jobseeker_initiate_message?(job_application)
    case job_application.status
    when "interviewing", "unsuccessful_interview", "offered", "declined"
      true
    else
      false
    end
  end

  def can_jobseeker_reply_to_message?(job_application)
    case job_application.status
    when "submitted", "shortlisted", "interviewing", "unsuccessful_interview", "offered", "declined"
      true
    else
      false
    end
  end

  def can_publisher_send_message?(job_application)
    case job_application.status
    when "withdrawn"
      false
    else
      true
    end
  end
end
