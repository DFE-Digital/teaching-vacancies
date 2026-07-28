class OrganisationLocationQuery < LocationQuery
  def initialize(scope)
    @scope = scope
  end

  def call(...)
    super("organisations.uk_geopoint", ...)
  end
end
