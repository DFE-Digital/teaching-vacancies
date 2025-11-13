desc "Discard subscriptions that fail validation (probably due to invalid email address)"
task discard_invalid_subscriptions: :environment do
  # these will be deleted by the tidy job really soon
  Subscription.find_each.reject(&:valid?).each(&:discard!)
end
