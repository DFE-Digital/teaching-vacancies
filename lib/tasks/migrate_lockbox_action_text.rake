namespace :lockbox do
  desc "Migrate ActionText::RichText encryption"
  task migrate_action_text: :environment do
    Lockbox.migrate(ActionText::RichText)
  end
end