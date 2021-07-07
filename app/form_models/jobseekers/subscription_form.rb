class Jobseekers::SubscriptionForm
  include ActiveModel::Model

  attr_accessor :email, :frequency,
                :keyword, :location, :radius,
                :job_roles, :phases, :working_patterns,
                :job_role_options, :suitable_nqts_options, :phase_options, :working_pattern_options,
                :variant

  validates :email, presence: true
  validates :email, format: { with: Devise.email_regexp }
  validates :frequency, presence: true

  validate :unique_job_alert
  validate :criteria_selected, if: -> { variant == :default }
  validate :location_and_one_other_criterion_selected, if: -> { variant == :mandatory_location_and_one_other_field }

  def initialize(params = {})
    search_criteria = params[:search_criteria]&.symbolize_keys || {}

    @email = params[:email]
    @frequency = params[:frequency]

    @keyword = params[:keyword] || search_criteria[:keyword]
    @location = params[:location] || search_criteria[:location]
    @radius = params[:radius] || search_criteria[:radius]

    @job_roles = params[:job_roles]&.reject(&:blank?) || search_criteria[:job_roles] || []
    @phases = params[:phases]&.reject(&:blank?) || search_criteria[:phases]
    @working_patterns = params[:working_patterns]&.reject(&:blank?) || search_criteria[:working_patterns]

    @variant = params[:variant]

    set_facet_options
  end

  def job_alert_params
    {
      email: email,
      frequency: frequency,
      search_criteria: search_criteria_hash,
    }
  end

  def search_criteria_hash
    {
      keyword: keyword,
      location: location,
      radius: radius,
      job_roles: job_roles,
      phases: phases,
      working_patterns: working_patterns,
    }.compact.delete_if { |_k, v| v.blank? || v.empty? }
  end

  private

  def set_facet_options
    @job_role_options = Vacancy.job_roles.except(:nqt_suitable).keys.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_details_form.job_roles_options.#{option}")] }
    @phase_options = [%w[primary Primary], %w[middle Middle], %w[secondary Secondary], %w[16-19 16-19]]
    @suitable_nqts_options = Vacancy.job_roles.slice(:nqt_suitable).keys.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_details_form.job_roles_options.#{option}")] }
    @working_pattern_options = Vacancy.working_patterns.keys.map do |option|
      [option, I18n.t("helpers.label.publishers_job_listing_job_details_form.working_patterns_options.#{option}")]
    end
  end

  def criteria_selected
    errors.add(:base, I18n.t("subscriptions.errors.no_criteria_selected")) if
      keyword.blank? && location.blank? && job_roles.blank? && phases.blank? && working_patterns.blank?
  end

  def location_and_one_other_criterion_selected
    errors.add(:base, I18n.t("subscriptions.errors.no_location_and_other_criterion_selected")) unless
      location.present? && %i[keyword job_roles phases working_patterns].any? { |criterion| public_send(criterion).present? }
  end

  def unique_job_alert
    return if frequency.blank?
    return unless Subscription.where(job_alert_params).exists?

    errors.add(:base, I18n.t("subscriptions.errors.duplicate_alert"))
  end
end
