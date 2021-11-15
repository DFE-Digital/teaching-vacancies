class AddGoogleIndexRemovedToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :google_index_removed, :boolean, default: false
  end
end
