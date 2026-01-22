class AddPreEmploymentChecks < ActiveRecord::Migration[8.0]
  def change
    create_table :pre_employment_check_sets, id: :uuid do |t|
      t.references :job_application, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.boolean :identity_check, null: false, default: false
      t.boolean :enhanced_dbs_check, null: false, default: false
      t.boolean :mental_and_physical_fitness, null: false, default: false
      t.boolean :right_to_work_in_uk, null: false, default: false
      t.boolean :professional_qualifications, null: false, default: false
      t.boolean :childrens_barred_list, null: false, default: false
      t.boolean :overseas_checks, null: false, default: false
      t.timestamps
    end
  end
end
