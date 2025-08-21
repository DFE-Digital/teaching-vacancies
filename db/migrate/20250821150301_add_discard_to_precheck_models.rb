class AddDiscardToPrecheckModels < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :self_disclosures, :discarded_at, :datetime
    add_column :self_disclosure_requests, :discarded_at, :datetime
    add_column :job_references, :discarded_at, :datetime
    add_column :reference_requests, :discarded_at, :datetime
    add_column :job_applications, :discarded_at, :datetime

    add_index :self_disclosures, :discarded_at, algorithm: :concurrently
    add_index :self_disclosure_requests, :discarded_at, algorithm: :concurrently
    add_index :job_references, :discarded_at, algorithm: :concurrently
    add_index :reference_requests, :discarded_at, algorithm: :concurrently
    add_index :job_applications, :discarded_at, algorithm: :concurrently
  end
end
