class Jobseekers::CloseAccount
  attr_reader :jobseeker, :close_account_feedback_form_params

  def initialize(jobseeker, close_account_feedback_form_params)
    @jobseeker = jobseeker
    @close_account_feedback_form_params = close_account_feedback_form_params
  end

  def call
    mark_jobseeker_account_closed
    create_feedback
    send_email_to_jobseeker
    mark_subscriptions_inactive
    withdraw_job_applications
  end

  private

  def mark_jobseeker_account_closed
    jobseeker.update!(account_closed_on: Date.current)
  end

  def create_feedback
    return unless close_account_feedback_form_params.values.any?(&:present?)

    jobseeker.feedbacks.close_account.create!(close_account_feedback_form_params)
  end

  def send_email_to_jobseeker
    Jobseekers::AccountMailer.account_closed(jobseeker).deliver_later
  end

  def mark_subscriptions_inactive
    Subscription.kept
                .where(email: jobseeker.email)
                .each(&:discard!)
  end

  def withdraw_job_applications
    jobseeker.job_applications
             .where(withdrawn_by_closing_account: false, status: %w[submitted reviewed shortlisted])
             .each { |job_application| withdrawn_job_application(job_application) }
  end

  def withdrawn_job_application(job_application)
    job_application.update!(withdrawn_by_closing_account: true,
                           withdrawn_at: Time.current,
                           status: :withdrawn)
  end
end
