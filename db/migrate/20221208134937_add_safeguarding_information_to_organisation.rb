class AddSafeguardingInformationToOrganisation < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :safeguarding_information, :string
  end
end
