class SupportUsers::FeedbacksController < SupportUsers::BaseController
  include SupportUsers::SatisfactionRatingTypes

  before_action :set_reporting_period, except: [:recategorize]

  def general
    @feedbacks = Feedback
      .with_comments_or_contactable
      .order(created_at: :desc)
      .where(created_at: @reporting_period.date_range)

    @categories = Feedback::NON_JOB_ALERT_CATEGORIES
    @categories_for_select = @categories.invert

    respond_to do |format|
      format.html
      format.csv { send_data general_feedback_csv(@feedbacks), filename: "general-feedback-#{Date.today}.csv" }
    end
  end

  def job_alerts
    @feedbacks = Feedback
      .job_alerts
      .order(created_at: :desc)
      .where(created_at: @reporting_period.date_range)

    @categories = Feedback::JOB_ALERT_CATEGORIES
    @categories_for_select = @categories.invert

    respond_to do |format|
      format.html
      format.csv { send_data job_alerts_feedback_csv(@feedbacks), filename: "job-alerts-feedback-#{Date.today}.csv" }
    end
  end

  def satisfaction_ratings
    @satisfaction_rating_type = SATISFACTION_RATING_TYPES.find { |type| type[:feedback_type] == params[:satisfaction_rating_type]&.to_sym } || SATISFACTION_RATING_TYPES.first
    @satisfaction_ratings ||= SATISFACTION_RATING_TYPES
    @summaries = satisfaction_rating_summaries(feedback_type: @satisfaction_rating_type[:feedback_type],
                                               grouping_key: @satisfaction_rating_type[:grouping_key])

    respond_to do |format|
      format.html
      format.csv { send_data satisfaction_ratings_csv(@summaries), filename: "#{params[:satisfaction_rating_type]}-#{Date.today}.csv" }
    end
  end

  def recategorize
    params.fetch(:feedbacks, []).each do |feedback_params|
      next if (category = feedback_params[:category]).blank?

      Feedback
        .find_by(id: feedback_params.fetch(:id))
        &.update(category: category)
    end

    reporting_period_params = { reporting_period: { from: params[:reporting_period_from],
                                                    to: params[:reporting_period_to] } }

    case params[:tab]
    when "job_alerts"
      redirect_to support_users_feedback_job_alerts_path(reporting_period_params)
    else
      redirect_to support_users_feedback_general_path(reporting_period_params)
    end
  end

  private

  def general_feedback_csv(feedbacks)
    generate_csv(feedbacks, "general")
  end

  def job_alerts_feedback_csv(feedbacks)
    generate_csv(feedbacks, "job_alerts")
  end

  def satisfaction_ratings_csv(summaries)
    generate_csv(summaries, "satisfaction_ratings")
  end

  def generate_csv(feedbacks, feedback_category)
    CSV.generate do |csv|
      csv << headings(feedback_category)

      feedbacks.each do |feedback|
        csv << row(feedback_category, feedback)
      end
    end
  end

  def headings(feedback_category)
    case feedback_category
    when "general"
      ["Created at", "Source", "Who", "Type", "Origin path", "Contact email", "Occupation", "CSAT", "Comment", "Category"]
    when "job_alerts"
      ["Timestamp", "Relevant?", "Comment", "Criteria", "Keyword", "Location", "Radius", "Working patterns", "Category"]
    when "satisfaction_ratings"
      @satisfaction_rating_type[:feedback_responses].map { |response| t(".#{@satisfaction_rating_type[:feedback_type]}.table_headings.#{response}") }.prepend("Reporting period")
    end
  end

  def row(feedback_category, feedback)
    case feedback_category
    when "general"
      [feedback.created_at, source_for(feedback), who(feedback), feedback.feedback_type, feedback.origin_path, contact_email_for(feedback), feedback.occupation, feedback.rating, feedback.comment, feedback.category]
    when "job_alerts"
      search_criteria = feedback.search_criteria || {}
      [feedback.created_at, feedback.relevant_to_user, feedback.comment, search_criteria.keys, search_criteria["keyword"], search_criteria["location"], search_criteria["radius"], feedback.category]
    when "satisfaction_ratings"
      @satisfaction_rating_type[:feedback_responses].map { |response| feedback[:results][response] || "0" }.prepend(feedback[:period].to_s)
    end
  end

  def source_for(feedback)
    identified_or_authenticated(feedback)
  end
  helper_method :source_for

  def who(feedback)
    user_type(feedback)
  end
  helper_method :who

  def contact_email_for(feedback)
    feedback.email if feedback.user_participation_response == "interested"
  end
  helper_method :contact_email_for

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
    if %i[jobseeker_account job_alert application unsubscribe].include?(feedback.feedback_type) || feedback.visit_purpose == "find_teaching_job"
      "jobseeker"
    elsif %i[vacancy_publisher].include?(feedback.feedback_type) || feedback.visit_purpose == "list_teaching_job"
      "hiring staff"
    else
      "unknown"
    end
  end

  def set_reporting_period
    @reporting_period = FeedbackReportingPeriod.new(
      from: reporting_period_params&.fetch(:from).presence || Date.today.at_beginning_of_month,
      to: reporting_period_params&.fetch(:to).presence || Date.today,
    )
  end

  def satisfaction_rating_summaries(feedback_type:, grouping_key:)
    FeedbackReportingPeriod.all.last(52).reverse_each.map do |period|
      {
        period: period,
        results: Feedback.where(feedback_type: feedback_type, created_at: period.date_range).group(grouping_key).count,
      }
    end
  end

  def reporting_period_params
    params.permit(reporting_period: %i[from to])[:reporting_period]
  end
end
