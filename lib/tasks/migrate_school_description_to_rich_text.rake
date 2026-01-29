desc "Migrates organisation descriptions from legacy string column to ActionText"
task migrate_school_description_to_rich_text: :environment do
  Organisation.find_each do |org|
    legacy_text = org.read_attribute(:description)

    next if legacy_text.blank? || org.description.present?

    begin
      org.update!(description: legacy_text)
    rescue StandardError => e
      Rails.logger.error "Error migrating Organisation #{org.id}: #{e.message}"
    end
  end
  puts "Migration complete."
end
