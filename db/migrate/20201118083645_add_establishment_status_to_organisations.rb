class AddEstablishmentStatusToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :establishment_status, :string
  end
end
