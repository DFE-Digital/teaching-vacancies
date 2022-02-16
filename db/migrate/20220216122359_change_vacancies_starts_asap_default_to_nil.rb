class ChangeVacanciesStartsAsapDefaultToNil < ActiveRecord::Migration[6.1]
  def change
    change_column_default :vacancies, :starts_asap, from: false, to: nil
  end
end
