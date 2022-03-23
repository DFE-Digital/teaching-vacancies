class SupportUsers::FeedbacksController < SupportUsers::BaseController
  def general
    @feedbacks = Feedback
      .except_job_alerts
      .order(created_at: :desc)
      .where(created_at: reporting_period.date_range)

    @categories = Feedback::NON_JOB_ALERT_CATEGORIES
    @categories_for_select = @categories.invert
  end

  def job_alerts
    @feedbacks = Feedback
      .job_alerts
      .order(created_at: :desc)
      .where(created_at: reporting_period.date_range)

    @categories = Feedback::JOB_ALERT_CATEGORIES
    @categories_for_select = @categories.invert
  end

  def recategorize
    params.fetch(:feedbacks).each do |feedback_params|
      next if (category = feedback_params[:category]).blank?

      Feedback
        .find_by(id: feedback_params.fetch(:id))
        &.update(category: category)
    end

    case params[:tab]
    when "job_alerts"
      redirect_to support_users_feedback_job_alerts_path(reporting_period: params[:reporting_period])
    else
      redirect_to support_users_feedback_general_path(reporting_period: params[:reporting_period])
    end
  end

  private

  def source_for(feedback)
    [identified_or_authenticated(feedback), user_type(feedback)].compact
  end
  helper_method :source_for

  def who(feedback)
    user_type(feedback)
  end
  helper_method :who

  def identified_or_authenticated(feedback)
    if authenticated?(feedback)
      "authenticated"
    elsif identified?(feedback)
      "identified"
    else
      "unidentified"
    end
  end

  def identified?(feedback)
    feedback.email.present?
  end

  def authenticated?(feedback)
    feedback.jobseeker_id || feedback.publisher_id
  end

  def user_type(feedback)
    if authenticated?(feedback)
      authenticated_user_type(feedback)
    else
      unauthenticated_user_type(feedback)
    end
  end

  def authenticated_user_type(feedback)
    if feedback.jobseeker_id
      "jobseeker"
    else
      "hiring staff"
    end
  end

  def unauthenticated_user_type(feedback)
    if %i[jobseeker_account job_alert application unsubscribe].include?(feedback.feedback_type)
      "jobseeker"
    elsif %i[vacancy_publisher].include?(feedback.feedback_type)
      "hiring staff"
    end
  end

  def reporting_period
    FeedbackReportingPeriod.for(params[:reporting_period].presence || Date.today)
  end
end
