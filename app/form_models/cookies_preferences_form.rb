class CookiesPreferencesForm
  include ActiveModel::Model

  attr_accessor :cookies_consent

  validates :cookies_consent, inclusion: { in: %w[yes no] }

  def initialize(params = {})
    @cookies_consent = params[:cookies_consent]
  end
end
