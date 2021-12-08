class Publishers::JobListing::ApplyingForTheJobForm < Publishers::JobListing::VacancyForm
  before_validation :override_enable_job_applications!

  validates :enable_job_applications, inclusion: { in: [true, false, "true", "false"] }
  validates :how_to_apply, presence: true, unless: proc { enable_job_applications.in?(["true", true]) }
  validates :application_link, url: true, if: proc { application_link.present? }
  validate :application_link_valid_uri, if: proc { application_link.present? }

  validates :contact_email, presence: true
  validates :contact_email, email_address: true, if: proc { contact_email.present? }

  validates :contact_number, format: { with: /\A\+?(?:\d\s?){10,12}\z/ }, if: proc { contact_number.present? }

  def self.fields
    %i[
      application_link enable_job_applications contact_email contact_number
      personal_statement_guidance school_visits how_to_apply
    ]
  end
  attr_accessor(*fields)

  def application_link=(link)
    @application_link = Addressable::URI.heuristic_parse(link).to_s
  rescue Addressable::URI::InvalidURIError
    @application_link = link
  end

  private

  def application_link_valid_uri
    Addressable::URI.heuristic_parse(application_link)
  rescue Addressable::URI::InvalidURIError
    errors.add(:application_link, I18n.t("applying_for_the_job_errors.application_link.url"))
  end

  def override_enable_job_applications!
    # If a publisher is signed in as an LA, we do not allow them to set the job applications feature.
    # This forces the field to be set so the validations pass when submitting the form (despite the
    # field not being there).
    # TODO: Remove params[:current_organisation].local_authority? (and conditional in view) when we start allowing applications feature for LAs

    # If a Publisher publishes a vacancy for a job role that does not allow enabling job applications
    # but then changes the job role to one that does, enable_job_applications is nil, meaning the validation
    # for this field does not pass. We want the validations for the enable_job_applications field to pass
    # to prevent an error from being displayed on the review page in this situation when validate_all_steps is run.
    self.enable_job_applications = false if (params[:current_organisation].local_authority? || vacancy.listed?) && enable_job_applications.blank?
  end
end
