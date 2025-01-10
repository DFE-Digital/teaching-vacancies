class AddStatutoryInductionCompleteDetailsToJobApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :job_applications, :statutory_induction_complete_details, :string
  end
end
