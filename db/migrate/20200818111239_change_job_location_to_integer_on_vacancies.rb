class ChangeJobLocationToIntegerOnVacancies < ActiveRecord::Migration[5.2]
  def up
    change_column :vacancies, :job_location, :integer, using: 'job_location::integer'
  end

  def down
    change_column :vacancies, :job_location, :string
  end
end
