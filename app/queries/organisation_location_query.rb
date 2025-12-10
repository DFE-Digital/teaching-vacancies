class OrganisationLocationQuery < LocationQuery
  def initialize(scope = Organisation.all)
    @scope = scope
  end

  def call(...)
    super("organisations.uk_geopoint", ...)
  end
end
