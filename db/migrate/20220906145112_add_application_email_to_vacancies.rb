class AddApplicationEmailToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :application_email, :string
  end
end
