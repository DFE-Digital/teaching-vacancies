class CreatePersonalDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :personal_details, id: :uuid do |t|
      t.references :jobseeker_profile, null: false, foreign_key: true, type: :uuid
      t.string :first_name
      t.string :last_name
      t.boolean :phone_number_provided
      t.string :phone_number
      t.json :completed_steps, default: {}, null: false

      t.timestamps
    end
  end
end
