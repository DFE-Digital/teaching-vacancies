# Make RGeo use lenient assertions
#
# The ActiveRecord PostGIS adapter casts PostGIS geometry columns as RGeo objects. These are
# validated on initialization, regardless of whether or not we actually do anything with them
# (we don't in this app). Due to a lack of precision causing rounding errors, some of the
# denser polygons we deal with fail this validation check (even though PostGIS can deal with
# them just fine).
#
# This sets the default RGeo factory to one that uses lenient assertions, which will be the
# default in RGeo 3.0. This means geometries are only validated at the point of use rather
# than at initialization.
#
# c.f. https://github.com/rgeo/activerecord-postgis-adapter/issues/312#issuecomment-920896634
#
# TODO: Remove when we have upgraded to rgeo gem >= 3.0

RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
  config.default = RGeo::Geographic.spherical_factory(srid: 4326, uses_lenient_assertions: true, buffer_resolution: 8)
end
