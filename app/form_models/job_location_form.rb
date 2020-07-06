class JobLocationForm < VacancyForm
  validates :job_location, inclusion: { in: %w[at_one_school central_office] }
end
