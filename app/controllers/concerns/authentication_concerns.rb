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
    current_school || current_school_group
  end

  def current_school
    @current_school ||= School.find_by!(urn: session[:urn]) if session[:urn].present?
  end

  def current_school_group
    if SchoolGroupJobsFeature.enabled?
      @current_school_group ||= SchoolGroup.find_by!(uid: session[:uid]) if session[:uid].present?
    end
  end
end
