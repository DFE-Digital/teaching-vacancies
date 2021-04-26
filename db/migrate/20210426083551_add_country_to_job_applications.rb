class AddCountryToJobApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :country, :string, default: "", null: false
  end
end
