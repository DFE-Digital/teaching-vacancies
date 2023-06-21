class CookiesPreferencesForm < BaseForm
  include ActiveModel::Model

  attr_accessor :cookies_analytics_consent, :cookies_marketing_consent

  validates :cookies_analytics_consent, inclusion: { in: %w[yes no] }
  validates :cookies_marketing_consent, inclusion: { in: %w[yes no] }
end
