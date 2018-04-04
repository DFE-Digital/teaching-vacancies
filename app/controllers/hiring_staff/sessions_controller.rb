class HiringStaff::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[create new destroy failure]

  # TODO: Bug with create when CSRF enabled. Obviously we need this before we can merge.
  protect_from_forgery with: :exception, except: :create

  def new
    redirect_to_azure
  end

  def create
    session.update(urn: '110627')
    redirect_to school_path(current_school.id)
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

  private def oid
    auth_hash['extra']['raw_info']['id_token_claims']['oid']
  end

  private def urn
    return ENV.fetch('DEFAULT_SCHOOL_URN') { School.first.urn } unless oid
    '110627' if urn.eql?('ff01631e-eaa6-4bdd-bb78-b563012c42b5')
  end

  protected def auth_hash
    request.env['omniauth.auth']
  end
end
