class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes, id: :uuid do |t|
      t.string :content
      t.references :publisher, null: false, foreign_key: true, type: :uuid
      t.references :job_application, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
 