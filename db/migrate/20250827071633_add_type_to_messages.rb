class AddTypeToMessages < ActiveRecord::Migration[7.2]
  def change
    safety_assured { add_column :messages, :type, :string, null: false }
  end
end
