namespace :notifications do
  desc "Migrate notification data to Noticed::Event"
  task migrate: :environment do
    Notification.find_each do |notification|
      attributes = notification.attributes.slice("type", "created_at", "updated_at").with_indifferent_access
      attributes[:type] = attributes[:type].sub("Notification", "Notifier")
      attributes[:params] = Noticed::Coder.load(notification.params)
      attributes[:params] = {} if attributes[:params].try(:has_key?, "noticed_error") # Skip invalid records

      attributes[:notifications_attributes] = [{
        type: "#{attributes[:type]}::Notification",
        recipient_type: notification.recipient_type,
        recipient_id: notification.recipient_id,
        read_at: notification.read_at,
        seen_at: notification.read_at, # Assuming `seen_at` should be the same as `read_at`
        created_at: notification.created_at,
        updated_at: notification.updated_at,
      }]

      Noticed::Event.create!(attributes)
    end
  rescue StandardError => e
    puts "An error occurred: #{e.message}"
  end
end
