class AddTypeToMessages < ActiveRecord::Migration[7.2]
  def change
    # rubocop:disable Rails/NotNullColumn
    safety_assured { add_column :messages, :type, :string, null: false }
    # rubocop:enable Rails/NotNullColumn
  end
end
