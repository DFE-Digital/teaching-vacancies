module NotifyViewHelper
  def notify_link(url, text = url)
    "[#{text}](#{url})"
  end

  def notify_mail_to(mail_to, text = mail_to)
    notify_link("mailto:#{mail_to}", text)
  end

  def edit_link(subscription)
    url = edit_subscription_url(subscription.token, params: utm_params(subscription))
    notify_link(url, t(".edit_link_text"))
  end

  def home_page_link(subscription)
    url = root_url(params: utm_params(subscription))
    notify_link(url, t("app.title"))
  end

  def job_alert_feedback_url(relevant, subscription, vacancies)
    new_subscription_job_alert_feedback_url(
      subscription.token,
      params: { job_alert_feedback: { relevant_to_user: relevant,
                                      job_alert_vacancy_ids: vacancies.pluck(:id),
                                      search_criteria: subscription.search_criteria } },
    )
  end

  def show_link(vacancy, subscription)
    url = vacancy.share_url(**utm_params(subscription))
    text = vacancy.job_title
    notify_link(url, text)
  end

  def sign_up_link(subscription)
    notify_link(new_jobseeker_registration_url(params: utm_params(subscription)), t(".create_account.link"))
  end

  def unsubscribe_link(subscription)
    url = unsubscribe_subscription_url(subscription.token, params: utm_params(subscription))
    notify_link(url, t(".unsubscribe_link_text"))
  end

  private

  def utm_params(subscription)
    { utm_source: subscription.alert_run_today&.id, utm_medium: "email", utm_campaign: "#{subscription.frequency}_alert" }
  end
end
