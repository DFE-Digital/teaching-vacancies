class MarkerLocationQuery < LocationQuery
  def initialize(scope = Marker.all)
    @scope = scope
  end

  def call(...)
    super("markers.geopoint", ...)
  end
end
