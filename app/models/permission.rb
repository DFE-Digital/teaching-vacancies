class Permission
  USER_TO_SCHOOL_MAPPING = {
    'a-valid-oid' => '110627'
  }.freeze

  def initialize(identifier:)
    @identifier = identifier
  end

  def valid?
    school_urn.present?
  end

  def school_urn
    USER_TO_SCHOOL_MAPPING[@identifier]
  end
end
