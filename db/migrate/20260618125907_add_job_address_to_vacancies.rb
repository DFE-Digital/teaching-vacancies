class AddJobAddressToVacancies < ActiveRecord::Migration[8.0]
  def change
    add_column :vacancies, :job_address_line1, :string
    add_column :vacancies, :job_address_line2, :string
    add_column :vacancies, :job_address_town, :string
    add_column :vacancies, :job_address_county, :string
    add_column :vacancies, :job_address_postcode, :string
  end
end
