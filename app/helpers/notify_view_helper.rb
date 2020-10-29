module NotifyViewHelper
  def notify_link(url, text = url)
    "[#{text}](#{url})"
  end

  def home_page_link
    url = root_url(protocol: 'https')
    text = t('app.title')
    notify_link(url, text)
  end

  def unsubscribe_link(subscription)
    url = unsubscribe_url(subscription)
    text = t('.unsubscribe_link_text')
    notify_link(url, text)
  end

  def edit_link(subscription)
    url = edit_url(subscription)
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

  def edit_url(subscription)
    utm_params = utm_params(subscription)
    params = { protocol: 'https' }
    if utm_params.present?
      params.merge!(
        utm_source: utm_params[:source],
        utm_medium: utm_params[:medium],
        utm_campaign: utm_params[:campaign],
        utm_content: utm_params[:content],
      )
    end
    Rails.application.routes.url_helpers.edit_subscription_url(subscription.token, params)
  end

  def unsubscribe_url(subscription)
    utm_params = utm_params(subscription)
    params = { protocol: 'https' }
    if utm_params.present?
      params.merge!(
        utm_source: utm_params[:source],
        utm_medium: utm_params[:medium],
        utm_campaign: utm_params[:campaign],
        utm_content: utm_params[:content],
      )
    end
    Rails.application.routes.url_helpers.unsubscribe_subscription_url(subscription.token, params)
  end
end
