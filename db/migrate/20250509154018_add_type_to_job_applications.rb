class AddTypeToJobApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :job_applications, :type, :string
  end
end
