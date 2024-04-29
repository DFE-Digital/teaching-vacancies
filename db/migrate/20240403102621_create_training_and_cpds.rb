class CreateTrainingAndCpds < ActiveRecord::Migration[7.1]
  def change
    create_table :training_and_cpds, id: :uuid do |t|
      t.string :name
      t.string :provider
      t.string :grade
      t.string :year_awarded

      t.timestamps
    end
  end
end
