class UpdateSubscriptionsWithNewWorkingPatterns
  def self.run!
    Subscription.all.each do |s|
      search_criteria_hash = s.search_criteria_to_h
      # Old format hash = {"subject"=>"english", "working_pattern"=>"full_time"}
      # New format hash = {"subject"=>"english", "working_patterns"=>["full_time"]}
      search_criteria_hash.transform_keys! { |k| k.gsub(/working_pattern\b/, 'working_patterns') }
                          .transform_values! {
                            |v| search_criteria_hash.key(v) == 'working_patterns' && v.is_a?(String) ? [v] : v
                          }
      s.search_criteria = search_criteria_hash.to_json
      s.save!
    end
  end
end


namespace :subscription_records do
  desc 'converts old working pattern subscriptions to array style'
  task convert_subscriptions: :environment do
    UpdateSubscriptionsWithNewWorkingPatterns.run!
  end
end
