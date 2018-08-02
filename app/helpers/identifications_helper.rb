module IdentificationsHelper
  DFE_SIGN_IN_OPTIONS = [
    OpenStruct.new(
      name: I18n.t('sign_in.option.milton_keynes').downcase,
      to_radio: [I18n.t('sign_in.milton_keynes.other').downcase, I18n.t('sign_in.milton_keynes.other')]
    )
  ].freeze

  # For the temporary purposes of usability testing for hiring staff that belong
  # to a school we've not yet rolled out to.
  STAGING_DFE_SIGN_IN_OPTIONS = [
    OpenStruct.new(
      name: I18n.t('sign_in.option.other').downcase,
      to_radio: [I18n.t('sign_in.option.other').downcase, I18n.t('sign_in.option.other')]
    )
  ].freeze

  AZURE_SIGN_IN_OPTIONS = [
    OpenStruct.new(name: 'cambridgeshire', to_radio: ['cambridgeshire', 'Cambridgeshire']),
    OpenStruct.new(name: 'the_north_east', to_radio: ['the_north_east', 'The North East'])
  ].freeze

  def identification_options
    @identification_options ||= begin
      opts = AZURE_SIGN_IN_OPTIONS.map(&:to_radio)
      opts += DFE_SIGN_IN_OPTIONS.map(&:to_radio) unless Rails.env.production?
      opts += STAGING_DFE_SIGN_IN_OPTIONS.map(&:to_radio) if Rails.env.staging?
      opts
    end
  end

  def schools_to_radio(schools)
    schools.inject([]) do |school_options, school|
      school_options << [school.urn, school.name]
    end
  end
end
