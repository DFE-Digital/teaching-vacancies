class AddMagicLinkTokenToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :magic_link_token, :string, unique: true
    add_column :users, :magic_link_token_sent_at, :datetime

    add_index :users, :magic_link_token, unique: true
  end
end
