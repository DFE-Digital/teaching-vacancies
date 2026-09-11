class RemoveReferrerCountsIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index :vacancy_analytics, :referrer_counts, algorithm: :concurrently
  end
end
