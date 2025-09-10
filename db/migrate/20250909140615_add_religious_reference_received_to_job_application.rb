class AddReligiousReferenceReceivedToJobApplication < ActiveRecord::Migration[7.2]
  def change
    create_table :religious_reference do |t|
      t.references :job_applications
      t.boolean :religious_reference_received, default: false, null: false
      t.timestamps
    end
  end
end
