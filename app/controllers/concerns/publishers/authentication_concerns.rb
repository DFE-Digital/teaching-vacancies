module Publishers::AuthenticationConcerns
  extend ActiveSupport::Concern

  included do
    helper_method :publisher_signed_in?
    helper_method :current_organisation
    helper_method :current_school
    helper_method :current_school_group
    helper_method :current_publisher_is_part_of_school_group?
  end

  def publisher_signed_in?
    session.key?(:publisher_oid)
  end

  def sign_out_publisher!
    %i[
      organisation_la_code
      organisation_uid
      organisation_urn
      publisher_id_token
      publisher_multiple_organisations
      publisher_oid
    ].each { |key| session.delete(key) }
  end

  def current_publisher_oid
    session.to_h["publisher_oid"]
  end

  def current_organisation
    current_school || current_school_group
  end

  def current_school
    @current_school ||= School.find_by!(urn: session[:organisation_urn]) if session[:organisation_urn].present?
  end

  def current_school_group
    if session[:organisation_uid].present?
      @current_school_group ||= SchoolGroup.find_by!(uid: session[:organisation_uid])
    elsif session[:organisation_la_code].present?
      @current_school_group ||= SchoolGroup.find_by!(local_authority_code: session[:organisation_la_code])
    end
  end

  def current_publisher_is_part_of_school_group?
    session[:organisation_uid].present? || session[:organisation_la_code].present?
  end
end
