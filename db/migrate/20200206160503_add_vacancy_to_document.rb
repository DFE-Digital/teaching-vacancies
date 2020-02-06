class AddVacancyToDocument < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :vacancy, foreign_key: true, type: :uuid
  end
end
