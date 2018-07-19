module IdentificationsHelper
  OTHER_SIGN_IN_OPTION = [
    OpenStruct.new(name: 'other', to_radio: ['other', 'Other'])
  ].freeze

  DFE_SIGN_IN_OPTIONS = [
    OpenStruct.new(name: 'milton_keynes', to_radio: ['milton_keynes', 'Milton Keynes'])
  ].freeze

  AZURE_SIGN_IN_OPTIONS = [
    OpenStruct.new(name: 'cambridgeshire', to_radio: ['cambridgeshire', 'Cambridgeshire']),
    OpenStruct.new(name: 'the_north_east', to_radio: ['the_north_east', 'The North East'])
  ].freeze

  def identification_options
    @identification_options ||=
      AZURE_SIGN_IN_OPTIONS.map(&:to_radio) +
      DFE_SIGN_IN_OPTIONS.map(&:to_radio) +
      OTHER_SIGN_IN_OPTION.map(&:to_radio)
  end
end
