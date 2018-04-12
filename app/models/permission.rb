class Permission
  USER_TO_SCHOOL_MAPPING = {
    'a5161a87-94d6-4723-823b-90d10a5760d6' => '137138', # test@
    '0535c532-31e2-4170-9846-225f5b1347aa' => '110627',
    '232c8b26-f336-4465-bc9a-e887cafaa95a' => '137138'
  }.freeze

  def initialize(identifier:)
    @identifier = identifier
  end

  def valid?
    school_urn.present?
  end

  def school_urn
    return ENV['OVERRIDE_SCHOOL_URN'] if !Rails.env.production? && ENV['OVERRIDE_SCHOOL_URN'].present?
    USER_TO_SCHOOL_MAPPING[@identifier]
  end
end
