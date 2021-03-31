class CreateReferences < ActiveRecord::Migration[6.1]
  def change
    create_table :references, id: :uuid do |t|
      t.string :name, default: "", null: false
      t.string :job_title, default: "", null: false
      t.string :organisation, default: "", null: false
      t.string :relationship, default: "", null: false
      t.string :email, default: "", null: false
      t.string :phone_number, default: "", null: false
      t.uuid :job_application_id, null: false

      t.timestamps
    end
  end
end
