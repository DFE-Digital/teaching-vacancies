class CreateQualificationResults < ActiveRecord::Migration[6.1]
  def change
    create_table :qualification_results, id: :uuid do |t|
      t.belongs_to :qualification, null: false, foreign_key: true, type: :uuid
      t.string :subject, null: false
      t.string :grade, null: false

      t.timestamps
    end
  end
end
