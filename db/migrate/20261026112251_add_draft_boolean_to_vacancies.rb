class AddDraftBooleanToVacancies < ActiveRecord::Migration[8.1]
  def change
    # TODO: needs a multi-stage PR plan to deploy properly
    add_column :vacancies, :draft, :boolean, null: false, default: true
  end
end
