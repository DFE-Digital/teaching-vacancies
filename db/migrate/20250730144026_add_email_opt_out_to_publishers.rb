class AddEmailOptOutToPublishers < ActiveRecord::Migration[7.2]
  def change
    add_column :publishers, :email_opt_out, :boolean, null: false, default: false
  end
end
