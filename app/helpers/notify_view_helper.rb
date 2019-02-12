module NotifyViewHelper
  def notify_link(url, text = url)
    "[#{text}](#{url})"
  end

  def unsubscribe_link(token)
    link_text = t('subscriptions.email.unsubscribe_link_text')
    notify_link(subscription_unsubscribe_url(subscription_id: token), link_text)
  end
end