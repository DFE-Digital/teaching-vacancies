class AddReadablePhaseToOrganisations < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :readable_phases, :string, array: true
  end
end
