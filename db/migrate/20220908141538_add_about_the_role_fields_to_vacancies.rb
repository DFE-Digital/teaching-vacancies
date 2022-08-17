class AddAboutTheRoleFieldsToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :skills_and_experience, :string
    add_column :vacancies, :school_offer, :string
    add_column :vacancies, :safeguarding_information_provided, :boolean
    add_column :vacancies, :safeguarding_information, :string
    add_column :vacancies, :further_details_provided, :boolean
    add_column :vacancies, :further_details, :string
  end
end
