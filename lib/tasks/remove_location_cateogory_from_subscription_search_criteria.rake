namespace :subscription do
  desc "remove location_category from search_criteria"
  task remove_location_category_from_search_criteria: :environment do
    Subscription.find_each do |subscription|
      subscription.search_criteria["location"] = subscription.search_criteria.delete("location_category")
      subscription.save
    end
  end
end
