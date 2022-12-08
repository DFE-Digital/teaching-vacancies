class Publishers::Organisation::UrlOverrideForm < BaseForm
  attr_accessor :url_override

  validates :url_override, url: { allow_blank: true }
end
