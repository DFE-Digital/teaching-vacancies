class Publishers::JobListing::ApplyingForTheJobDetailsForm < Publishers::JobListing::UploadBaseForm
  attr_accessor :application_form

  validates :how_to_apply, presence: true, unless: proc { vacancy.enable_job_applications.in?(["true", true]) }
  validates :application_link, url: true, if: proc { application_link.present? }
  validate :application_link_valid_uri, if: proc { application_link.present? }

  validates :contact_email, presence: true
  validates :contact_email, email_address: true, if: proc { contact_email.present? }

  validates :contact_number, format: { with: /\A\+?(?:\d\s?){10,12}\z/ }, if: proc { contact_number.present? }

  def self.fields
    %i[
      application_link contact_email contact_number
      personal_statement_guidance school_visits how_to_apply
    ]
  end
  attr_accessor(*fields)

  def valid_application_form
    return unless valid_file_size?(application_form) && valid_file_type?(application_form) && virus_free?(application_form)

    @valid_application_form ||= application_form
  end

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
end
