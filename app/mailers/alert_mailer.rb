class AlertMailer < ApplicationMailer
  self.delivery_job = AlertMailerJob
  helper DatesHelper

  def alert(subscription_id, vacancy_ids)
    subscription = Subscription.find(subscription_id)
    @subscription = SubscriptionPresenter.new(subscription)
    vacancies = Vacancy.where(id: vacancy_ids).order(:expires_at)
    @vacancies = VacanciesPresenter.new(vacancies)
    template = @subscription.daily? ? NOTIFY_SUBSCRIPTION_DAILY_TEMPLATE : NOTIFY_SUBSCRIPTION_WEEKLY_TEMPLATE

    view_mail(
      template,
      to: @subscription.email,
      subject: I18n.t("alert_mailer.alert.subject"),
    )
  end
end
