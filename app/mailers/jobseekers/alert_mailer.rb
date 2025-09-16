class Jobseekers::AlertMailer < Jobseekers::BaseMailer
  rescue_from Notifications::Client::BadRequestError, with: :handle_invalid_email_exception
  INVALID_EMAIL_REGEXP = %r{ValidationError: email_address}

  after_action :jobseeker

  self.delivery_job = AlertMailerJob
  helper DatesHelper
  helper VacanciesHelper

  helper_method :subscription, :jobseeker, :jobseeker_has_profile?

  def alert(subscription_id, vacancy_ids)
    @subscription_id = subscription_id

    @vacancies = PublishedVacancy.where(id: vacancy_ids)
                   .order(:expires_at)
                   .map { |vacancy| VacancyPresenter.new(vacancy) }

    send_email(to: subscription.email,
               subject: I18n.t("jobseekers.alert_mailer.alert.subject",
                               count: @vacancies.count,
                               count_minus_one: @vacancies.count - 1,
                               job_title: @vacancies.first.job_title,
                               school_name: @vacancies.first.organisation_name))
  end

  private

  attr_reader :subscription_id

  def handle_invalid_email_exception(exception)
    return subscription.destroy! if exception.message.match?(INVALID_EMAIL_REGEXP)

    raise exception
  end

  def dfe_analytics_custom_data
    { subscription_identifier: subscription.id, subscription_frequency: subscription.frequency }
  end

  def email_event_prefix
    "jobseeker_subscription"
  end

  def jobseeker
    return @jobseeker if defined?(@jobseeker)

    @jobseeker = Jobseeker.find_by(email: subscription.email)
  end

  def subscription
    @subscription ||= SubscriptionPresenter.new(Subscription.find(subscription_id))
  end

  def jobseeker_has_profile?
    return false unless jobseeker

    jobseeker.jobseeker_profile.present?
  end

  def utm_campaign
    "#{subscription.frequency}_alert"
  end
end
