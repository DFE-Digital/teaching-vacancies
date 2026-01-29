class MigrateSchoolDescriptionToRichText < ActiveRecord::Migration[8.0]
  def up
    Organisation.find_each do |org|
      old_text = org.read_attribute(:description)
      next if old_text.blank?

      org.update!(description: old_text)
    end
  end

  def down
    Organisation.find_each do |org|
      if org.description.body.present?
        org.update_column(:description, org.description.body.to_html)
      end
    end
  end
end
