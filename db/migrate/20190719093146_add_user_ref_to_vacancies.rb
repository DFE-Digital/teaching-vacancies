class AddUserRefToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_reference :vacancies, :user, foreign_key: true, type: :uuid
  end
end
