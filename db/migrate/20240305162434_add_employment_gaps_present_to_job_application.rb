class AddEmploymentGapsPresentToJobApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :job_applications, :employment_gaps_present, :boolean
  end
end
