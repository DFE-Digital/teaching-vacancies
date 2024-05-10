class Publishers::JobListing::JobRoleForm < Publishers::JobListing::VacancyForm
  validates :job_roles, presence: { message: "At least one job role is required" }
  validate :job_roles_inclusion

  def self.fields
    %i[job_roles]
  end
  attr_accessor(*fields)

  def job_roles
    params[:job_roles]
  end

  def params_to_save
    { job_roles: job_roles }
  end

  def teaching_job_roles_options
    Vacancy::TEACHING_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.teaching_job_role_options.#{option}")] }
  end

  def teaching_support_job_roles_options
    Vacancy::TEACHING_SUPPORT_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.teaching_support_job_role_options.#{option}")] }
  end

  def non_teaching_support_job_roles_options
    Vacancy::NON_TEACHING_SUPPORT_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.non_teaching_support_job_role_options.#{option}")] }
  end

  def support_job_roles_options
    Vacancy::SUPPORT_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.support_job_role_options.#{option}")] }
  end

  def job_roles_inclusion
    return unless job_roles

    job_roles.each do |role|
      errors.add(:job_roles, "Invalid job role") unless Vacancy.job_roles.key?(role)
    end
  end
end
