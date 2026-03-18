class Publishers::JobListing::JobRoleForm < Publishers::JobListing::JobListingForm
  validates :job_roles, presence: { message: "At least one job role is required" }
  validate :job_roles_inclusion, if: -> { job_roles.present? }

  FIELDS = %i[job_roles].freeze
  attr_accessor(*FIELDS)

  class << self
    # rubocop:disable Lint/UnusedMethodArgument
    def load_from_model(vacancy, current_publisher:)
      new(vacancy.slice(*FIELDS))
    end
    # rubocop:enable Lint/UnusedMethodArgument

    def fields
      { job_roles: [] }
    end
  end

  def params_to_save
    { job_roles: job_roles }
  end

  def job_roles_inclusion
    job_roles.each do |role|
      errors.add(:job_roles, "Invalid job role") unless Vacancy.job_roles.key?(role)
    end
  end
end
