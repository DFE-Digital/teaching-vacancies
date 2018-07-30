module IdentificationsHelper
  DFE_SIGN_IN_OPTIONS = [
    OpenStruct.new(name: 'milton_keynes', to_radio: ['milton_keynes', 'Milton Keynes'])
  ].freeze

  AZURE_SIGN_IN_OPTIONS = [
    OpenStruct.new(name: 'cambridgeshire', to_radio: ['cambridgeshire', 'Cambridgeshire']),
    OpenStruct.new(name: 'the_north_east', to_radio: ['the_north_east', 'The North East'])
  ].freeze

  def identification_options
    @identification_options ||= begin
      opts = AZURE_SIGN_IN_OPTIONS.map(&:to_radio)
      opts += DFE_SIGN_IN_OPTIONS.map(&:to_radio)
      opts
    end
  end

  def schools_to_radio(schools)
    schools.inject([]) do |school_options, school|
      school_options << [school.urn, school.name]
    end
  end
end
