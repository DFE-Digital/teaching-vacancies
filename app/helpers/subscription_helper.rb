module SubscriptionHelper
  def frequency_options
    Subscription.frequencies.keys.map do |frequency|
      [frequency, I18n.t("subscriptions.frequency.#{frequency}")]
    end
  end
end
