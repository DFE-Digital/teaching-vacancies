class Publishers::Organisation::UrlOverrideForm < BaseForm
  attr_reader :url_override

  validates :url_override, url: { allow_blank: true }

  def url_override=(link)
    @url_override = Addressable::URI.heuristic_parse(link).to_s
  rescue Addressable::URI::InvalidURIError
    @url_override = link
  end
end
