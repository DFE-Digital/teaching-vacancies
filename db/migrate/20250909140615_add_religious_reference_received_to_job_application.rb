class AddReligiousReferenceReceivedToJobApplication < ActiveRecord::Migration[7.2]
  def change
    create_table :religious_reference_requests, id: :uuid do |t|
      t.references :job_application, foreign_key: true, type: :uuid, null: false, index: { unique: true }
      t.integer :status, null: false
      t.timestamps
    end
  end
end
