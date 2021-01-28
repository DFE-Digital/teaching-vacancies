namespace :subscriptions do
  desc "Convert search criteria from JSON string to Hash"
  task convert_search_criteria: :environment do
    Subscription.find_each { |s| s.update_column :search_criteria, JSON.parse(s.search_criteria) if s.search_criteria.is_a?(String) }
  end
end
