module AuthenticationConcerns
  extend ActiveSupport::Concern

  included do
    helper_method :authenticated?
    helper_method :current_organisation
    helper_method :current_school
    helper_method :current_school_group
  end

  def authenticated?
    session[:session_id].present?
  end

  def current_organisation
    if SchoolGroupJobsFeature.enabled?
      current_school_group || current_school
    else
      current_school
    end
  end

  def current_school
    @current_school ||= School.find_by!(urn: session[:urn])
  end

  def current_school_group
    @current_school_group ||= SchoolGroup.find_by!(uid: session[:uid])
  end
end
