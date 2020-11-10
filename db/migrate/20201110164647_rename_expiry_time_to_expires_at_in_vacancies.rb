class RenameExpiryTimeToExpiresAtInVacancies < ActiveRecord::Migration[6.0]
  def change
    rename_column :vacancies, :expiry_time, :expires_at
  end
end
