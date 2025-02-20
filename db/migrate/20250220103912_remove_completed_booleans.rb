class RemoveCompletedBooleans < ActiveRecord::Migration[7.2]
  def change
    safety_assured {
      %i[training_and_cpds_section_completed employment_history_section_completed qualifications_section_completed].each do |column|
        remove_column :job_applications, column
      end
    }
  end
end
