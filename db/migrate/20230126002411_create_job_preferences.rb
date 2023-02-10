class CreateJobPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :job_preferences, id: :uuid do |t|
      t.references :jobseeker, type: :uuid, foreign_key: true
      t.string :roles, array: true, default: []
      t.string :phases, array: true, default: []
      t.string :key_stages, array: true, default: []
      t.string :subjects, array: true, default: []
      t.string :working_patterns, array: true, default: []
      t.json :locations, array: true, default: []
      t.json :completed_steps, default: {}
      t.boolean :builder_completed, default: false, null: false

      t.timestamps
    end
  end
end
