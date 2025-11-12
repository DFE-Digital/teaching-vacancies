namespace :db do
  desc "Discard subscriptions that fail validation (probably due to inavlid email address)"
  task discard_invalid_subscriptions: :environment do
    Subscription.find_each.reject(&:valid?).each(&:discard!)
  end
end
