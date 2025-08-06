class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages, id: :uuid do |t|
      t.text :content
      t.references :job_application, null: false, foreign_key: true, type: :uuid
      t.references :sender, polymorphic: true, null: false, type: :uuid

      t.timestamps
    end
  end
end
