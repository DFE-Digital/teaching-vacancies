class AddReferenceNumberToVacancy < ActiveRecord::Migration[5.1]
  def change
    remove_column :vacancies, :reference, :string
    add_column :vacancies, :reference, :uuid, default: "gen_random_uuid()", null: false, unique: true
  end
end
