module FeedbacksHelper
  def current_user_email(current_jobseeker, current_publisher)
    current_jobseeker&.email.presence || current_publisher&.email.presence
  end

  def header_feedback_link_text
    capture do
      concat("This is a new service - ")
      concat(govuk_link_to("your feedback", feedback_url))
      concat(" will help us to improve it.")
    end
  end

  def footer_feedback_link_text
    capture do
      link_text = t("footer.provide_feedback")
      concat(link_to(link_text, feedback_url, class: "govuk-footer__link"))
    end
  end

  def feedback_url
    if jobseeker_signed_in?
      new_jobseekers_account_feedback_path(origin: url_for)
    else
      new_feedback_path
    end
  end
end
