class CookiesPreferencesForm < BaseForm
  include ActiveModel::Model

  attr_accessor :cookies_consent

  validates :cookies_consent, inclusion: { in: %w[yes no] }
end
