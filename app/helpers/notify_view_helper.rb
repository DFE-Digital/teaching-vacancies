module NotifyViewHelper
  def notify_link(url, text = url)
    "[#{text}](#{url})"
  end

  def home_page_link
    url = root_url(protocol: 'https')
    text = t('app.title')
    notify_link(url, text)
  end

  def unsubscribe_link(token)
    url = unsubscribe_subscription_url(token, protocol: 'https')
    text = t('.unsubscribe_link_text')
    notify_link(url, text)
  end

  def edit_link(token)
    url = edit_subscription_url(token, protocol: 'https')
    text = t('.edit_link_text')
    notify_link(url, text)
  end

  def show_link(vacancy, subscription)
    url = vacancy.share_url(source: 'subscription', medium: 'email', campaign: "#{subscription.frequency}_alert")
    text = vacancy.job_title
    notify_link(url, text)
  end

  def job_alert_feedback_url(relevant, subscription, vacancies)
    new_subscription_feedback_url(
      subscription.token,
      protocol: 'https',
      params: { job_alert_feedback: { relevant_to_user: relevant,
                                      vacancy_ids: vacancies.pluck(:id),
                                      search_criteria: JSON.parse(subscription.search_criteria) } },
    )
  end
end
