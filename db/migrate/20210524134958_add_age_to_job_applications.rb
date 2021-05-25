class AddAgeToJobApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :age, :string, default: "", null: false
  end
end
