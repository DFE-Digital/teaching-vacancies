desc "Migrate existing ActionText rich text bodies to encrypted format"
task encrypt_action_text: :environment do
  Lockbox.migrate(ActionText::RichText)
end
