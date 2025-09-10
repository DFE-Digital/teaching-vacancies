class AddReligiousReferenceReceivedToJobApplication < ActiveRecord::Migration[7.2]
  def change
    add_column :job_applications, :religious_reference_received, :boolean, default: false, null: false
  end
end
