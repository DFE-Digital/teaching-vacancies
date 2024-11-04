class CampaignSearchParamsMerger
  def initialize(url_params, campaign_page)
    @url_params = url_params
    @campaign_page = campaign_page
  end

  def merged_params
    params = @url_params.to_h.symbolize_keys
    sanitise_campaign_params(params)
    merge_campaign_criteria(params)
    map_location_and_radius(params)
    map_teaching_job_roles_subjects_phases(params)
    extract_working_patterns(params)
    extract_ect_status(params)
    params
  end

  private

  attr_reader :url_params, :campaign_page

  def sanitise_campaign_params(params)
    params.each do |key, value|
      params[key] = if value.blank? || value.strip.empty? || value == "%20"
                      nil
                    else
                      value.strip
                    end
    end
  end

  def merge_campaign_criteria(params)
    return unless campaign_page&.criteria

    campaign_page.criteria.each do |key, value|
      params[key] ||= value
    end
  end

  def map_location_and_radius(params)
    params[:location] = params.delete(:email_location) if params[:email_location].present?
    params[:radius] = params.delete(:email_radius) if params[:email_radius].present?
  end

  def map_teaching_job_roles_subjects_phases(params)
    params[:teaching_job_roles] = [params.delete(:email_jobrole)].compact if params[:email_jobrole].present?
    params[:subjects] = [params.delete(:email_subject)].compact if params[:email_subject].present?
    params[:phases] = [params.delete(:email_phase)].compact if params[:email_phase].present?
  end

  def extract_working_patterns(params)
    working_patterns = []
    working_patterns << "full_time" if ActiveModel::Type::Boolean.new.cast(params.delete(:email_fulltime))
    working_patterns << "part_time" if ActiveModel::Type::Boolean.new.cast(params.delete(:email_parttime))
    working_patterns << "job_share" if ActiveModel::Type::Boolean.new.cast(params.delete(:email_jobshare))
    params[:working_patterns] = working_patterns unless working_patterns.empty?
  end

  def extract_ect_status(params)
    ect_value = params.delete(:email_ECT)
    params[:ect_statuses] = if ect_value.present? && ActiveModel::Type::Boolean.new.cast(ect_value)
                              %w[ect_suitable]
                            else
                              %w[ect_unsuitable]
                            end
  end
end
