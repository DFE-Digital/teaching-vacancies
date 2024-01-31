class AddExternalSourceIndexToVacancies < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :vacancies, [:external_source, :external_reference], algorithm: :concurrently
  end
end
