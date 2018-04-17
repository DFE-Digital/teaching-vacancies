class Permission
  USER_TO_SCHOOL_MAPPING = {
    'a5161a87-94d6-4723-823b-90d10a5760d6' => '137138', # test@
    '0535c532-31e2-4170-9846-225f5b1347aa' => '110627', # benwick@
    '3e2728aa-958c-42fe-9890-39f6d8b8496a' => '137138', # bexleyheath@
    '7d842528-52c8-49db-9deb-6bd4d9aaf7c8' => '111692', # fiona@
    'd486e1aa-180c-4871-8c26-f12a590cdac3' => '137060', # tolworthtest@
    '64f35537-9d8f-468d-ab81-e73ba328970e' => '137060', # tolworth@
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
