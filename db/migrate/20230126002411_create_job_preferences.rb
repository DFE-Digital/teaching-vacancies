class CreateJobPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :job_preferences, id: :uuid do |t|
      t.string :roles, array: true, default: []
      t.string :phases, array: true, default: []
      t.string :key_stages, array: true, default: []
      t.string :working_patterns, array: true, default: []
      t.string :subjects, array: true, default: []

      t.timestamps
    end
  end
end
