namespace :jobseeker_alerts do
  desc 'Backfills data about jobseeker alerts'
  namespace :statistics do
    namespace :backfill do
      task alert_data: :environment do
        Subscription.all.each do |s|
          subscription = SubscriptionPresenter.new(s)
          AuditData.create(category: :subscription_creation, data: subscription.to_row)
        end
      end
    end
  end
end
