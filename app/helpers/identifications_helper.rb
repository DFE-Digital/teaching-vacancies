module IdentificationsHelper
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

  def identification_options
    @identification_options ||=
      AZURE_SIGN_IN_OPTIONS.map(&:to_radio) +
      DFE_SIGN_IN_OPTIONS.map(&:to_radio) +
      OTHER_SIGN_IN_OPTION.map(&:to_radio)
  end
end
