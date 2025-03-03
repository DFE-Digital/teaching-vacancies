class RemoveGapsInEmploymentField < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :job_applications, :gaps_in_employment, :string, default: "", null: false }
  end
end
