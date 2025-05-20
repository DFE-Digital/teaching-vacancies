class AddDiscardedAtToVacancies < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :vacancies, :discarded_at, :datetime
    add_index :vacancies, :discarded_at, algorithm: :concurrently
  end
end
