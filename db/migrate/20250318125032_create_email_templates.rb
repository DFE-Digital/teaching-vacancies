class CreateEmailTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :email_templates, id: :uuid do |t|
      t.uuid :publisher_id, null: false, index: true

      t.string :name, null: false
      t.string :from, null: false
      t.string :subject, null: false

      t.timestamps
    end

    add_foreign_key :email_templates, :publishers
  end
end
