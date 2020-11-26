class RemoveTrailingWhitespacesFromSubscriptionSearchCriteria < ActiveRecord::Migration[6.0]
  def change
    Subscription.find_each(batch_size: 100) do |subscription|
      new_criteria = {}
      JSON.parse(subscription.search_criteria).each do |field, value|
        new_criteria[field] = if value.is_a?(String)
                                value.strip
                              else
                                value
                              end
      end
      subscription.update!(search_criteria: new_criteria.to_json)
    end
  end
end
