class NqtJobAlertsForm
  include ActiveModel::Model

  attr_accessor :keywords, :location, :email
  attr_writer :location_reference

  validates :keywords, presence: true
  validates :location, presence: true
  validates :email, email_address: { presence: true }

  validate :unique_job_alert

  def initialize(params = {})
    @keywords = params[:keywords]
    @location = params[:location]
    @email = params[:email]
    @location_reference = location_reference
  end

  def job_alert_params
    {
      email: email,
      frequency: :daily,
      search_criteria: nqt_job_alert_hash.to_json
    }
  end

  def location_reference
    if location.present? && location_category
      I18n.t("subscriptions.location_category_text", location: location_category)
    else
      I18n.t("subscriptions.location_radius_text", location: location, radius: 10)
    end
  end

private

  def nqt_job_alert_hash
    {
      keyword: "nqt #{keywords}",
      location: location,
      radius: 10,
      location_category: location_category.presence
    }.compact
  end

  def location_category
    LocationCategory.include?(location) ? location : false
  end

  def unique_job_alert
    errors.add(:base, I18n.t("subscriptions.errors.duplicate_alert")) if
      SubscriptionFinder.new(job_alert_params).exists?
  end
end
