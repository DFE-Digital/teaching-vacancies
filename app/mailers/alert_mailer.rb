class AlertMailer < ApplicationMailer
  self.delivery_job = DailyAlertMailerJob
  add_template_helper(DateHelper)

  def daily_alert(subscription_id, vacancy_ids)
    subscription = Subscription.find(subscription_id)
    vacancies = Vacancy.where(id: vacancy_ids).order(:expires_on)

    @email = subscription.email
    @subscription_reference = subscription.reference
    @expires_on = subscription.expires_on
    @unsubscribe_token = subscription.token
    @vacancies = VacanciesPresenter.new(vacancies, searched: false)

    view_mail(
      NOTIFY_SUBSCRIPTION_DAILY_TEMPLATE,
      to: subscription.email,
      subject: I18n.t('alerts.email.daily.subject', count: vacancies.count),
    )
  end
end