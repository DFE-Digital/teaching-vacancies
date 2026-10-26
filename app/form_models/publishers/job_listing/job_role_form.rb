class Publishers::JobListing::JobRoleForm < Publishers::JobListing::JobListingForm
  FIELDS = %i[job_roles].freeze
  attr_accessor(*FIELDS)

  class << self
    def fields
      { job_roles: [] }
    end

    def field_list
      %i[job_roles]
    end
  end

  def params_to_save
    { job_roles: job_roles }
  end
end
