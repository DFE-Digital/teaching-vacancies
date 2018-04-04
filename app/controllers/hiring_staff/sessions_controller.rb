class HiringStaff::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[create new destroy failure]

  # TODO: Bug with create when CSRF enabled. Obviously we need this before we can merge.
  protect_from_forgery with: :exception, except: :create

  def new
    redirect_to_azure
  end

  def create
    if hiring_staff_authorised?
      session.update(urn: permission_mappings[oid])

      redirect_to school_path(current_school.id)
    else
      redirect_to root_path, notice: I18n.t('errors.sign_in.unauthorised')
    end
  end

  def failure
    Rollbar.log('error', 'Sign in provider returned a failure')
    render html: I18n.t('errors.sign_in.failure')
  end

  def destroy
    session.destroy
    redirect_to root_path, notice: I18n.t('access.signed_out')
  end

  private def redirect_to_azure
    # Defined by Azure AD strategy: https://github.com/AzureAD/omniauth-azure-activedirectory#usage
    redirect_to '/auth/azureactivedirectory'
  end

  private def hiring_staff_authorised?
    permission_mappings[oid].present?
  end

  private def permission_mappings
    { 'a-valid-oid' => '110627' }
  end

  private def auth_hash
    request.env['omniauth.auth']
  end

  private def oid
    auth_hash['extra']['raw_info']['id_token_claims']['oid']
  end
end
