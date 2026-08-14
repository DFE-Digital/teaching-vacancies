class Publishers::Organisation::UrlOverrideForm < BaseForm
  include ActiveModel::Attributes
  include ActiveModel::Attributes::Normalization

  attribute :url_override, :string
  normalizes :url_override, with: ->(url_override) { url_override.strip }

  validates :url_override, url: { allow_blank: true }
end
