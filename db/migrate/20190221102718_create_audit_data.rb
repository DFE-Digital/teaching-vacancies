class CreateAuditData < ActiveRecord::Migration[5.2]
  def change
    create_table :audit_data, id: :uuid do |t|
      t.integer :category
      t.json :data

      t.timestamps
    end
  end
end
