class OrganisationLocationQuery < LocationQuery
  def initialize(scope)
    @scope = scope
  end

  def call(...)
    super("organisations.geopoint", ...)
  end
end
