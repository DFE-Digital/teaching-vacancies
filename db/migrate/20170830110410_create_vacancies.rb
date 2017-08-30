class CreateVacancies < ActiveRecord::Migration[5.1]
  def change
    create_table :vacancies do |t|
      # Job specification
      t.string :job_title, null: false
      t.string :slug, null: false
      t.string :headline, null: false
      t.text :job_description, null: false
      t.integer :minimum_salary, null: false
      t.integer :maximum_salary
      t.text :benefits
      t.integer :working_pattern
      t.float :full_time_equivalent
      t.integer :weekly_hours
      t.date :starts_on
      t.date :ends_on
      t.references :subject, index: true
      t.references :pay_scale, index: true
      t.references :leadership, index: true
      # Candidate specification
      t.text :essential_requirements, null: false
      t.text :education
      t.text :qualifications
      t.text :experience
      # Vacancy details
      t.string :contact_email
      t.string :reference
      t.integer :status
      t.date :expires_on
      t.date :publish_on
      t.references :school, index: true

      t.timestamps
    end
  end
end
