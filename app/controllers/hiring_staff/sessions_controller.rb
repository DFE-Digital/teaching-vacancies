class HiringStaff::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[destroy]

  def destroy
    session.destroy
    redirect_to root_path, notice: I18n.t('messages.access.signed_out')
  end

  private

  def redirect_to_dfe_sign_in
    # This is defined by the class name of our Omniauth strategy
    redirect_to '/auth/dfe'
  end
end
