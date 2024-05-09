class Jobseekers::SubscriptionForm < BaseForm
  attr_accessor :email,
                :frequency,
                :keyword,
                :location,
                :radius,
                :teaching_job_roles,
                :teaching_support_job_roles,
                :non_teaching_support_job_roles,
                :support_job_roles,
                :visa_sponsorship_availability,
                :ect_statuses,
                :subjects,
                :phases,
                :working_patterns,
                :teaching_job_role_options,
                :teaching_support_job_role_options,
                :non_teaching_support_job_role_options,
                :support_job_role_options,
                :visa_sponsorship_availability_options,
                :ect_status_options,
                :phase_options,
                :working_pattern_options,
                :organisation_slug,
                :campaign,
                :user_name

  validates :email, presence: true, email_address: true
  validates :frequency, presence: true
  validates :location, within_united_kingdom: true

  validate :unique_job_alert
  validate :location_and_one_other_criterion_selected, unless: :organisation_slug

  def initialize(params = {}) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
    search_criteria = params[:search_criteria]&.symbolize_keys || {}

    @email = params[:email]
    @frequency = params[:frequency]
    @keyword = params[:keyword] || search_criteria[:keyword]
    @location = params[:location] || search_criteria[:location]
    @teaching_job_roles = params[:teaching_job_roles]&.reject(&:blank?) || search_criteria[:teaching_job_roles] || []
    @teaching_support_job_roles = params[:teaching_support_job_roles]&.reject(&:blank?) || search_criteria[:teaching_support_job_roles] || []
    @non_teaching_support_job_roles = params[:non_teaching_support_job_roles]&.reject(&:blank?) || search_criteria[:non_teaching_support_job_roles] || []
    @support_job_roles = params[:support_job_roles]&.reject(&:blank?) || search_criteria[:support_job_roles] || []
    @visa_sponsorship_availability = params[:visa_sponsorship_availability]&.reject(&:blank?) || search_criteria[:visa_sponsorship_availability]
    @ect_statuses = params[:ect_statuses]&.reject(&:blank?) || search_criteria[:ect_statuses] || []
    @subjects = params[:subjects]&.reject(&:blank?) || search_criteria[:subjects]
    @phases = params[:phases]&.reject(&:blank?) || search_criteria[:phases]
    @working_patterns = params[:working_patterns]&.reject(&:blank?) || search_criteria[:working_patterns]
    @organisation_slug = params[:organisation_slug]
    @campaign = params[:campaign].presence || false
    @user_name = params[:user_name]

    set_radius((params[:radius] || search_criteria[:radius]))
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
      radius: (@location.present? ? radius : nil),
      teaching_job_roles: teaching_job_roles,
      teaching_support_job_roles: teaching_support_job_roles,
      non_teaching_support_job_roles: non_teaching_support_job_roles,
      support_job_roles: support_job_roles,
      visa_sponsorship_availability: visa_sponsorship_availability,
      ect_statuses: ect_statuses,
      subjects: subjects,
      phases: phases,
      working_patterns: working_patterns,
      organisation_slug: organisation_slug,
    }.compact.delete_if { |_k, v| v.blank? || v.empty? }
  end

  private

  def set_facet_options
    @visa_sponsorship_availability_options =  [["true", I18n.t("jobs.filters.visa_sponsorship_availability.subscriptions")]]
    @teaching_job_role_options = Vacancy::TEACHING_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.teaching_job_role_options.#{option}")] }
    @teaching_support_job_role_options = Vacancy::TEACHING_SUPPORT_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.teaching_support_job_role_options.#{option}")] }
    @support_job_role_options = Vacancy::SUPPORT_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.support_job_role_options.#{option}")] }
    @non_teaching_support_job_role_options = Vacancy::NON_TEACHING_SUPPORT_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.non_teaching_support_job_role_options.#{option}")] }
    @phase_options = Vacancy.phases.keys.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_education_phases_form.phases_options.#{option}")] }
    @ect_status_options = [["ect_suitable", I18n.t("jobs.filters.ect_suitable")]]
    @working_pattern_options = Vacancy.working_patterns.keys.map do |option|
      [option, I18n.t("helpers.label.publishers_job_listing_working_patterns_form.working_patterns_options.#{option}")]
    end
  end

  def location_and_one_other_criterion_selected
    errors.add(:base, I18n.t("subscriptions.errors.no_location_and_other_criterion_selected")) unless
      location.present? && %i[keyword teaching_job_roles teaching_support_job_roles non_teaching_support_job_roles support_job_roles subjects phases working_patterns].any? { |criterion| public_send(criterion).present? }
  end

  def unique_job_alert
    return if frequency.blank?
    return unless Subscription.where(job_alert_params).exists?

    errors.add(:base, I18n.t("subscriptions.errors.duplicate_alert"))
  end

  def set_radius(radius_param)
    @radius = Search::RadiusBuilder.new(location, radius_param).radius.to_s
  end
end
