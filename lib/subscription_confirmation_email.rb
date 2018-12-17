require 'services/notify'
class SubscriptionConfirmationEmail
  REFERENCE = 'subscription_confirmation'.freeze

  def initialize(subscription)
    @email = subscription.email
    @subscription_reference = subscription.reference
    @search_criteria = SubscriptionPresenter.new(subscription).filtered_search_criteria
    @expires_on = subscription.expires_on
    @unsubscribe_link = ''
  end

  def call
    Notify.new(email,
               personalisation,
               NOTIFY_SUBSCRIPTION_CONFIRMATION_TEMPLATE,
               REFERENCE).call
  end

  private

  attr_reader :email, :subscription_reference, :unsubscribe_link, :search_criteria, :expires_on

  def personalisation
    {
      subscription_reference: subscription_reference,
      body: body
    }
  end

  def body
    @body = heading(I18n.t('app.title'))
    @body << heading(I18n.t('subscriptions.email.confirmation.subheading'))
    search_criteria.each_pair do |key, value|
      @body << add_search_item(key, value)
    end
    @body << add_line(I18n.t('subscriptions.email.confirmation.expiry_text_html', distance: '3 months',
                                                                                  date: I18n.l(expires_on)))
    @body
  end

  def heading(text)
    "# #{text}\n"
  end

  def add_line(text)
    add_break << text << add_break
  end

  def add_break
    "\n"
  end

  def add_search_item(key, value)
    item = key.present? ? "#{key.titleize}: " : ''
    item << "#{value}\n"
    item
  end
end
