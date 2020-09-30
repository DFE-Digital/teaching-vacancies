class AlertMailer < ApplicationMailer
  self.delivery_job = DailyAlertMailerJob
  add_template_helper(DatesHelper)

  def daily_alert(subscription_id, vacancy_ids)
    subscription = Subscription.find(subscription_id)
    @subscription = SubscriptionPresenter.new(subscription)
    vacancies = Vacancy.where(id: vacancy_ids).order(:expires_on).order(:expiry_time)

    @vacancies = VacanciesPresenter.new(vacancies)

    view_mail(
      NOTIFY_SUBSCRIPTION_DAILY_TEMPLATE,
      to: @subscription.email,
      subject: I18n.t('job_alerts.alert.email.subject'),
    )
  end
end
