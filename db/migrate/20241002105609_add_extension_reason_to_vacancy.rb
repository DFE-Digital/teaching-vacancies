class AddExtensionReasonToVacancy < ActiveRecord::Migration[7.1]
  def change
    add_column :vacancies, :extension_reason, :integer
    add_column :vacancies, :other_extension_reason_details, :string
  end
end
