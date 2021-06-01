class Publishers::JobListing::ApplyingForTheJobForm < Publishers::JobListing::VacancyForm
  attr_accessor :application_link, :enable_job_applications, :contact_email, :contact_number, :personal_statement_guidance, :school_visits, :how_to_apply, :current_organisation

  before_validation :override_enable_job_applications_for_local_authority!

  validates :enable_job_applications, inclusion: { in: [true, false, "true", "false"] }, if: -> { JobseekerApplicationsFeature.enabled? }
  validates :how_to_apply, presence: true
  validates :application_link, url: true, if: proc { application_link.present? }

  validates :contact_email, presence: true
  validates :contact_email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, if: proc { contact_email.present? }

  validates :contact_number, format: { with: /\A\+?(?:\d\s?){10,12}\z/ }, if: proc { contact_number.present? }

  private

  # If a publisher is signed in as an LA, we do not allow them to set the job applications feature.
  # This forces the field to be set so the validations pass when submitting the form (despite the
  # field not being there).
  # TODO: Remove me (and conditional in view) when we start allowing applications feature for LAs
  def override_enable_job_applications_for_local_authority!
    return if params[:current_organisation].nil?
    return unless params[:current_organisation].local_authority? && enable_job_applications.blank?

    self.enable_job_applications = false
  end
end
