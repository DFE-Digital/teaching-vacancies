class HiringStaff::IdentificationsController < HiringStaff::BaseController
  include ActionView::Helpers::OutputSafetyHelper

  skip_before_action :check_session, only: %i[new create]
  skip_before_action :verify_authenticity_token, only: [:create]

  before_action :halt_other_regions, only: [:create]

  OTHER_SIGN_IN_OPTION = [
    OpenStruct.new(
      name: 'Other',
      to_radio: ['Other', 'Other']
    )
  ].freeze

  DFE_SIGN_IN_OPTIONS = [
    OpenStruct.new(
      name: 'Milton Keynes',
      to_radio: ['Milton Keynes', 'Milton Keynes']
    )
  ].freeze

  AZURE_SIGN_IN_OPTIONS = [
    OpenStruct.new(name: 'Cambridgeshire', to_radio: ['Cambridgeshire', 'Cambridgeshire']),
    OpenStruct.new(name: 'The North East', to_radio: ['The North East', 'The North East'])
  ].freeze

  def new
    @identification_options =
      AZURE_SIGN_IN_OPTIONS.map(&:to_radio) +
      DFE_SIGN_IN_OPTIONS.map(&:to_radio) +
      OTHER_SIGN_IN_OPTION.map(&:to_radio)
  end

  def create
    sign_in_path = new_azure_path
    sign_in_path = new_dfe_path if DFE_SIGN_IN_OPTIONS.map(&:name).include?(choice)

    logger.debug("Hiring staff identified as from the #{choice} district during sign in.")
    redirect_to sign_in_path
  end

  def choice
    params.require('identifications').permit('name')['name']
  end

  private def halt_other_regions
    return unless choice.eql?('Other')

    flash[:notice] = safe_join(
      [
        'Other areas have not been invited yet, please register your interest by emailing us at ',
        "<a href=mailto:#{I18n.t('help.email')}>#{I18n.t('help.email')}</a>".html_safe
      ]
    )

    redirect_to root_path
  end
end
