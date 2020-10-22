module NotifyViewHelper
  def notify_link(url, text = url)
    "[#{text}](#{url})"
  end

  def home_page_link
    url = root_url(protocol: 'https')
    text = t('app.title')
    notify_link(url, text)
  end

  # TODO: This one next
  def unsubscribe_link(token)
    url = unsubscribe_subscription_url(token, protocol: 'https')
    text = t('.unsubscribe_link_text')
    notify_link(url, text)
  end

  def edit_link(subscription)
    url = subscription.edit_url(**utm_params(subscription))
    text = t('.edit_link_text')
    notify_link(url, text)
  end

  def show_link(vacancy, subscription)
    url = vacancy.share_url(**utm_params(subscription))
    text = vacancy.job_title
    notify_link(url, text)
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

private

  def utm_params(subscription)
    { source: subscription.alert_run_today.id, medium: 'email', campaign: "#{subscription.frequency}_alert" }
  end
end
