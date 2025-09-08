module MessagingPermissions
  extend ActiveSupport::Concern

  # Jobseeker permissions
  def can_jobseeker_initiate_message?
    case status
    when "interviewing", "unsuccessful_interview", "offered", "declined"
      true
    else
      false
    end
  end

  def can_jobseeker_reply_to_message?
    case status
    when "submitted", "shortlisted", "interviewing", "unsuccessful_interview", "offered", "declined"
      true
    else
      false
    end
  end

  # Publisher/hiring staff permissions
  def can_publisher_send_message?
    case status
    when "withdrawn"
      false
    else
      true
    end
  end
end
