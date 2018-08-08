module IdentificationsHelper
  DFE_SIGN_IN_OPTIONS = [
    OpenStruct.new(name: 'milton_keynes', to_radio: ['milton_keynes', 'Milton Keynes']),
    OpenStruct.new(name: 'cambridgeshire', to_radio: ['cambridgeshire', 'Cambridgeshire']),
    OpenStruct.new(name: 'the_north_east', to_radio: ['the_north_east', 'The North East'])
  ].freeze

  def identification_options
    @identification_options ||= begin
      DFE_SIGN_IN_OPTIONS.map(&:to_radio)
    end
  end

  def schools_to_radio(schools)
    schools.inject([]) do |school_options, school|
      school_options << [school.urn, school.name]
    end
  end
end
