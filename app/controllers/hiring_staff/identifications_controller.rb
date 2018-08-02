class HiringStaff::IdentificationsController < HiringStaff::BaseController
  include ActionView::Helpers::OutputSafetyHelper
  include IdentificationsHelper

  skip_before_action :check_session, only: %i[new create]
  skip_before_action :verify_authenticity_token, only: [:create]

  before_action :redirect_signed_in_users

  def new; end

  def create
    sign_in_path = new_dfe_path
    sign_in_path = new_azure_path if AZURE_SIGN_IN_OPTIONS.map(&:name).include?(choice)

    logger.debug("Hiring staff identified as from the #{choice} district during sign in.")
    redirect_to sign_in_path
  end

  def choice
    params.require('identifications').permit('name')['name']
  end

  def redirect_signed_in_users
    return redirect_to school_path if session.key?(:urn)
  end
end
