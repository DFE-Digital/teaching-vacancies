class HiringStaff::SignIn::Dfe::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[create new]
  skip_before_action :check_terms_and_conditions, only: %i[create new]
  skip_before_action :verify_authenticity_token, only: %i[create new]

  def new
    # This is defined by the class name of our Omniauth strategy
    redirect_to '/auth/dfe'
  end

  def create
    permissions = TeacherVacancyAuthorisation::Permissions.new
    permissions.authorise(identifier, selected_school_urn)
    Auditor::Audit.new(nil, 'dfe-sign-in.authentication.success', current_session_id).log_without_association

    if permissions.authorised?
      update_session(permissions.school_urn, permissions)
      redirect_to school_path
    else
      Auditor::Audit.new(nil, 'dfe-sign-in.authorisation.failure', current_session_id).log_without_association
      log_debug_information
      redirect_to page_path('user-not-authorised')
    end
  end

  private

  def update_session(school_urn, permissions)
    session.update(session_id: oid, urn: school_urn, multiple_schools: permissions.many?)
    Auditor::Audit.new(current_school, 'dfe-sign-in.authorisation.success', current_session_id).log
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def oid
    auth_hash['uid']
  end

  def identifier
    auth_hash['info']['email']
  end

  def selected_school_urn
    auth_hash.dig('extra', 'raw_info', 'organisation', 'urn')
  end

  def log_debug_information
    anonymised_email = identifier.gsub(/(.)./, '\1*')
    logger.warn("Unauthenticated user for identifier: #{anonymised_email}, school_urn: #{selected_school_urn}")
  end
end
