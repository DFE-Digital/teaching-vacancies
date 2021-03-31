class CreateEmployments < ActiveRecord::Migration[6.1]
  def change
    create_table :employments, id: :uuid do |t|
      t.string :organisation, default: "", null: false
      t.string :job_title, default: "", null: false
      t.string :salary, default: "", null: false
      t.string :subjects, default: "", null: false
      t.string :current_role, default: "", null: false
      t.text :reason_for_leaving, default: "", null: false
      t.text :main_duties, default: "", null: false
      t.date :started_on
      t.date :ended_on
      t.uuid :job_application_id, null: false

      t.timestamps
    end
  end
end
