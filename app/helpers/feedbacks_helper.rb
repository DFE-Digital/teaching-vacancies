module FeedbacksHelper
  def current_user_email(current_jobseeker, current_publisher)
    current_jobseeker&.email.presence || current_publisher&.email.presence
  end
end
