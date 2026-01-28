class OrganisationLocationQuery < LocationQuery
  def initialize(scope = Organisation.all)
    @scope = scope
  end

  def call(...)
    super("organisations.geopoint", ...)
  end
end
