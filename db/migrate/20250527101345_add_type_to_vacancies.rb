class AddTypeToVacancies < ActiveRecord::Migration[7.2]
  def change
    safety_assured { add_column :vacancies, :type, :string, null: false, default: "PublishedVacancy" }
  end
end
