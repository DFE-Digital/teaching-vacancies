class Publishers::JobListing::JobRoleForm < Publishers::JobListing::VacancyForm
  validates :job_roles, inclusion: { in: Vacancy.job_roles.keys }

  def self.fields
    %i[job_roles]
  end
  attr_accessor(*fields)

  # The form is used for a "Choose one role" radio button selection.
  # The model/db contains the role in an array, given that some legacy vacancies with "senior_leader" and "middle_leader"
  # got splitted into multiple job_roles for a single vacancy.
  # The following methods ensure that we can:
  # A) Display the existing vacancy role selection as a radio button (by defaulting to the first role in the array).
  # B) Save the selection as an array (by mapping the value into an array).

  # incoming param is an array when loading the form from the DB values. It is a string when submitted by user selection.
  def job_roles
    params[:job_roles].is_a?(Array) ? params[:job_roles].first : params[:job_roles]
  end

  def params_to_save
    { job_roles: [job_roles] }
  end
end
