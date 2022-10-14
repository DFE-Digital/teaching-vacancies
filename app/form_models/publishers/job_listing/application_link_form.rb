class Publishers::JobListing::ApplicationLinkForm < Publishers::JobListing::VacancyForm
  validates :application_link, presence: true, url: true
  validate :application_link_valid_uri

  def self.fields
    %i[application_link]
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
end
