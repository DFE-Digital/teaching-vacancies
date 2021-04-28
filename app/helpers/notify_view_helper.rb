module NotifyViewHelper
  def notify_mail_to(mail_to, text = mail_to)
    notify_link("mailto:#{mail_to}", text)
  end

  def notify_link(url, text = url)
    "[#{text}](#{url})"
  end

  def edit_link(subscription, utm_campaign: "")
    url = edit_subscription_url(subscription.token, **utm_params(utm_campaign))
    notify_link(url, t(".edit_link_text"))
  end

  def home_page_link(utm_campaign: "")
    url = root_url(**utm_params(utm_campaign))
    notify_link(url, t("app.title"))
  end

  def job_alert_feedback_url(relevant, subscription, vacancies, utm_campaign: "")
    params = { job_alert_feedback: { relevant_to_user: relevant,
                                     job_alert_vacancy_ids: vacancies.pluck(:id),
                                     search_criteria: subscription.search_criteria } }.merge(utm_params(utm_campaign))
    new_subscription_job_alert_feedback_url(subscription.token, **params)
  end

  def show_link(vacancy, utm_campaign: "")
    url = vacancy.share_url(**utm_params(utm_campaign))
    notify_link(url, vacancy.job_title)
  end

  def sign_up_link(utm_campaign: "")
    url = new_jobseeker_registration_url(**utm_params(utm_campaign))
    notify_link(url, t(".create_account.link"))
  end

  def unsubscribe_link(subscription, utm_campaign: "")
    url = unsubscribe_subscription_url(subscription.token, **utm_params(utm_campaign))
    notify_link(url, t(".unsubscribe_link_text"))
  end

  private

  def utm_params(utm_campaign)
    { utm_source: uid, utm_medium: "email", utm_campaign: utm_campaign }
  end
end
