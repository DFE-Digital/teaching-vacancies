class AddMissingIndices < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :employments, :job_applications
    add_index :employments, :job_application_id

    add_foreign_key :equal_opportunities_reports, :vacancies
    add_index :equal_opportunities_reports, :vacancy_id

    add_foreign_key :job_applications, :vacancies
    add_index :job_applications, :vacancy_id

    add_index :organisations, :type

    add_index :publishers, :email

    add_foreign_key :qualifications, :job_applications
    add_index :qualifications, :job_application_id

    add_foreign_key :references, :job_applications
    add_index :references, :job_application_id

    add_foreign_key :saved_jobs, :jobseekers
    add_index :saved_jobs, :jobseeker_id

    add_index :school_group_memberships, %i[school_group_id school_id]

    add_index :subscriptions, :email

    add_index :vacancies, :slug
    add_index :vacancies, :status
  end
end
