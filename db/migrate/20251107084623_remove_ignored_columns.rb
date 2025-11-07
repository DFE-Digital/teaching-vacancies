class RemoveIgnoredColumns < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      %i[personal_statement_guidance how_to_apply school_visits_details].each do |column|
        remove_column :vacancies, column, :text
      end

      remove_column :subscriptions, :active, :boolean, default: true
    end
  end
end
