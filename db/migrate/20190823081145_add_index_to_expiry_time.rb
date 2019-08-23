class AddIndexToExpiryTime < ActiveRecord::Migration[5.2]
  def change
    add_index :vacancies, :expiry_time
  end
end
