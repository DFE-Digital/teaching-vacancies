class Publishers::JobListing::ApplicationLinkForm < Publishers::JobListing::VacancyForm
  validates :application_link, presence: true, url: true

  def self.fields
    %i[application_link]
  end
  attr_accessor(*fields)

  def application_link=(link)
    @application_link = Addressable::URI.heuristic_parse(link).to_s
  rescue Addressable::URI::InvalidURIError
    @application_link = link
  end
end
