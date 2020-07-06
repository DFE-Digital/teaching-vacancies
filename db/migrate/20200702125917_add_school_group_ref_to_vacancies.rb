class AddSchoolGroupRefToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_reference :vacancies, :school_group, foreign_key: true, type: :uuid
  end
end
