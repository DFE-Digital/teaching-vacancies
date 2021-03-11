class Jobseekers::AlertMailer < Jobseekers::BaseMailer
  self.delivery_job = AlertMailerJob
  helper DatesHelper

  helper_method :subscription, :jobseeker

  def alert(subscription_id, vacancy_ids)
    @subscription_id = subscription_id

    @template = subscription.daily? ? NOTIFY_SUBSCRIPTION_DAILY_TEMPLATE : NOTIFY_SUBSCRIPTION_WEEKLY_TEMPLATE
    @to = subscription.email

    @vacancies = VacanciesPresenter.new(Vacancy.where(id: vacancy_ids).order(:expires_at))

    view_mail(@template, to: @to, subject: I18n.t("jobseekers.alert_mailer.alert.subject"))
  end

  private

  def email_event_data
    { subscription_identifier: StringAnonymiser.new(subscription.id), subscription_frequency: subscription.frequency }
  end

  def email_event_prefix
    "jobseeker_subscription"
  end

  def jobseeker
    @jobseeker ||= Jobseeker.find_by(email: subscription.email)
  end

  def subscription
    @subscription ||= SubscriptionPresenter.new(Subscription.find(@subscription_id))
  end
end
