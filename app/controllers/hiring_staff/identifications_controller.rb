class HiringStaff::IdentificationsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[new create]
  skip_before_action :verify_authenticity_token, only: [:create]

  DFE_SIGN_IN_OPTIONS = [
    OpenStruct.new(name: 'Central Bedfordshire', to_radio: ['Central Bedfordshire', 'Central Bedfordshire']),
    OpenStruct.new(
      name: 'Any other local authority',
      to_radio: ['Any other local authority', 'Any other local authority']
    )
  ].freeze

  AZURE_SIGN_IN_OPTIONS = [
    OpenStruct.new(name: 'Cambridgeshire', to_radio: ['Cambridgeshire', 'Cambridgeshire']),
    OpenStruct.new(name: 'The North East', to_radio: ['The North East', 'The North East'])
  ].freeze

  def new
    @identification_options =
      AZURE_SIGN_IN_OPTIONS.map(&:to_radio) + DFE_SIGN_IN_OPTIONS.map(&:to_radio)
  end

  def create
    sign_in_path = new_azure_path
    sign_in_path = new_dfe_path if DFE_SIGN_IN_OPTIONS.map(&:name).include?(choice)

    redirect_to sign_in_path
  end

  def choice
    params.require('identifications').permit('name')['name']
  end
end
