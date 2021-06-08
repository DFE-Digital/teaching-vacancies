module FeedbackHelper
  def current_user_email(current_jobseeker, current_publisher)
    if current_jobseeker
      current_jobseeker.email
    elsif current_publisher
      current_publisher.email
    else
      ""
    end
  end
end
