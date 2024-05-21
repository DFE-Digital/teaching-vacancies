class AddImportedStepsToJobApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :job_applications, :imported_steps, :jsonb, default: {}, null: false
  end
end
