class CreateLocalAuthorities < ActiveRecord::Migration[5.1]
  def change
    create_table :local_authorities, id: :uuid do |t|
      t.string :code
      t.string :name

      t.timestamps
    end

    add_index :local_authorities, [:name, :code], unique: true
    add_index :local_authorities, :name, unique: true
  end
end
