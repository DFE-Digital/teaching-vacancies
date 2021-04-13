class CreateQualifications < ActiveRecord::Migration[6.1]
  def change
    create_table :qualifications, id: :uuid do |t|
      t.timestamps
      t.integer :category
      t.boolean :finished_studying
      t.text :finished_studying_details, default: "", null: false
      t.string :grade, default: "", null: false
      t.string :institution, default: "", null: false
      t.string :name, default: "", null: false
      t.string :subject, default: "", null: false
      t.integer :year
      t.uuid :job_application_id, null: false
    end
  end
end
