class RelocateJobReference < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      change_table :job_references do |t|
        t.references :reference_request, foreign_key: true, index: { unique: true }, type: :uuid
      end
      remove_column :job_references, :reference_id, :uuid
      change_column_null :job_references, :reference_request_id, false
    end
  end
end
