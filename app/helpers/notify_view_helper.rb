module NotifyViewHelper
  def notify_link(url, text = url)
    "[#{text}](#{url})"
  end

  def edit_link(subscription)
    url = edit_subscription_url(
      subscription.token,
      protocol: 'https',
      params: utm_params(subscription),
    )
    notify_link(url, t('.edit_link_text'))
  end

  def home_page_link(subscription)
    url = root_url(protocol: 'https', params: utm_params(subscription))
    notify_link(url, t('app.title'))
  end

  def job_alert_feedback_url(relevant, subscription, vacancies)
    new_subscription_job_alert_feedback_url(
      subscription.token,
      protocol: 'https',
      params: { job_alert_feedback: { relevant_to_user: relevant,
                                      vacancy_ids: vacancies.pluck(:id),
                                      search_criteria: JSON.parse(subscription.search_criteria) } },
    )
  end

  def show_link(vacancy, subscription)
    url = vacancy.share_url(**utm_params(subscription))
    text = vacancy.job_title
    notify_link(url, text)
  end

  def unsubscribe_link(subscription)
    url = unsubscribe_subscription_url(
      subscription.token,
      protocol: 'https',
      params: utm_params(subscription),
    )
    notify_link(url, t('.unsubscribe_link_text'))
  end

private

  def utm_params(subscription)
    { utm_source: subscription.alert_run_today.id, utm_medium: 'email', utm_campaign: "#{subscription.frequency}_alert" }
  end
end
