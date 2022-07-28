class Publishers::JobListing::JobRoleForm < Publishers::JobListing::VacancyForm
  validates :job_role, inclusion: { in: Vacancy.job_roles.keys }

  def self.fields
    %i[job_role]
  end
  attr_accessor(*fields)
end
