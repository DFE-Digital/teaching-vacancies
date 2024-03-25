class AddEmploymentGapsPresentToJobApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :job_applications, :unexplained_employment_gaps_present, :boolean
  end
end