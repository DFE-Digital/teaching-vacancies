namespace :subscription do
  desc "persist generated subscription keywords"
  task persist_generated_subscription_keywords: :environment do
    Subscription.find_each do |subscription|
      if subscription.search_criteria["keyword"].blank?
        subscription.search_criteria["keyword"] = subscription.keyword
        subscription.save
      end
    end
  end
end
