# Searching by Location

## Index
- [Introduction](#introduction)
- [Our approach](#our-approach)
- [How we store locations](#how-we-store-locations)
  - [Meaning of SRID 4326](#meaning-of-srid-4326)
  - [Why not just Geometry](#why-not-just-geometry)
  - [Performance](#performance)
    - [Spatial indexing](#spatial-indexing)
    - [Reducing Location Polygon areas complexity](#reducing-location-polygon-areas-complexity)
    - [Precomputing data when possible](#precomputing-data-when-possible)
    - [Tweaking queries to improve performance](#tweaking-queries-to-improve-performance)
    - [Increasing our database instance resources](#increasing-our-database-instance-resources)
- [Vacancies location](#vacancies-location)
- [How do we get the coordinates for the search location](#how-do-we-get-the-coordinates-for-the-search-location)
- [Location Polygons](#location-polygons)
  - [Purpose](#purpose)
  - [Mappings](#mappings)
- [Getting the geographical coordinates](#getting-the-geographical-coordinates)
  - [Google Geocoding API costs](#google-geocoding-api-costs)


## Introduction

Jobseekers searching for vacancies within a relative distance from a location is a core feature in Teaching Vacancies.

At the time this was written, around 70% of our vacancy searches include location in their filters.

## Our approach

Once a job search location is submitted, the service:

1. Gets the area or coordinates for the searched location.

2. Filters vacancies that, after being included by the rest of the search filters, are located within the provided radius distance from the given location.

3. To allow ordering the search results by distance, computes the exact distance between each vacancy and the given location.

## How we store locations

Our PostgreSQL database instance has the PostGIS extension.
This extension allows our database to store and operate with geospatial data.

The data type in the database is `geometry` with the `geographic: true` flag and `SRID 4326`.

What does this mean?

We store the data in a geographic coordinate system (GCS) rather than a projected coordinate system (PCS).
The coordinates are stored as latitude and longitude on the Earth's surface, following the WGS84 standard.

Using the `geometry` type with `geographic: true` allows us to leverage a wide range of PostGIS geospatial functions, such as `ST_Distance`, `ST_Within`, `ST_Intersects`, and `ST_Buffer`.

### Meaning of `SRID 4326`

- SRID: Spatial Referencing System ID.
- 4326: Represents spatial data using longitude and latitude coordinates on the Earth's surface as defined in the WGS84 standard.

The data type we use from PostGIS is `Geometry` with a `Geographic` coordinate system, which allows us to use projections and transformations.

### Why not just Geometry

When using a geographic coordinate system, distance calculations are performed on the curved surface of the Earth.
PostGIS functions like `ST_Distance` and `ST_Buffer` will take into account the Earth's curvature, providing more accurate results for large distances compared to a planar (flat) coordinate system.

When investigating the possibility of using Geometry and a Projected Coordinate System, we found that our search area (England, The UK) distances are large enough to need to take the Earth's curvature into account.

### Performance

Using `Geographic` data and operations requires more computational resources than using planar `Geometric` data.

We have mitigated the performance hit with a few measures:

#### Spatial indexing

We use PostGIS spatial indexing for any geospatial data used in our queries. Stored areas and points must have spatial indexes when used in any querying.

#### Reducing Location Polygon areas complexity

We have experienced major performance issues when some of our location polygons coming from ONS have tens of thousands of points (e.g., the Cornwall polygon consisted of 125k points).

Doing an `ST_Buffer` (expanding the polygon for radius searches) over polygons with that level of complexity is very taxing on the database CPU and memory.

Simplifying the polygons with some tolerance offers a major reduction in the polygon points while quite accurately keeping the polygon shape.
For example, the Cornwall polygon with 2.5k points instead of 125k is almost identical to the original while being way less resource-expensive to operate with.

To achieve that, we use `ST_SimplifyPreserveTopology` over the ONS imported polygons prior to storing them in our database.

#### Precomputing data when possible

Precomputing the `centroid` point for the location polygon areas and saving them in the database improves our search by distance queries performance. It avoids calculating each location polygon center to use it to calculate the polygon distance from each vacancy. Instead, it uses the stored centroid to calculate the distance.

#### Tweaking queries to improve performance

The `use_spheroid` parameter set to `false` turns to use a faster spherical calculation.

For example: `ST_Distance(gg1, gg2, false)`

#### Increasing our database instance resources

We originally had a basic Azure PostgreSQL Flexible server: `GP_Standard_D2ds` with 2 vCPUs and 8GB of RAM.

The memory was more than enough, the average CPU usage was low, the connections limit was well above what we were using... but our database CPU kept getting daily 100% usage spikes with location search queries, causing some very slow queries that triggered AKS pods restarting in our servers.

We upgraded to a `GP_Standard_D4ds`, which provides 4 vCPUs and 16GB of RAM.

The increase in CPU resources resolved the location search SQL queries performance issues. While they're still computationally expensive, the database instance has more than enough resources to swiftly manage those queries without choking or causing a bottleneck.

## Vacancies location

Each vacancy has location coordinates stored in their `geolocation` database field.

This field contains the geographic coordinates for the vacancy associated organization.

## How do we get the coordinates for the search location

Once a location is provided for a search, there are three possibilities:

1. The location is considered a **nationwide location** (e.g., England, UK..)

    We ignore the location. A nationwide location filter is irrelevant when all our vacancies are restricted to England.

2. **We have a polygon** stored for the given location.

    We create a buffered expanded area based on the provided search location radius.

3. **No polygon is found** for the given location.

    We get the geographical coordinates for the given location.

## Location Polygons

The location polygons are geographical areas we store in our database.

There is an [ImportPolygonDataJob](/app/jobs/import_polygon_data_job.rb) running weekly that imports polygons for:
- Counties
- Cities
- Regions

It also creates composite polygons combining the above.

All these imports are obtained [querying](/app/services/ons_data_import/base.rb) the ONS (Office for National Statistics) ArcGIS endpoints to obtain the area data for each of the polygons.

### Purpose

There is a difference between searching for vacancies within a particular distance from a jobseeker's home (that would match some particular coordinates point) and vacancies within a particular distance "from Essex".

How do we measure the distance between a whole region and a particular vacancy location?

Taking the center of the region would be wrong. As if, let's say, we search for "10 miles from Essex" anything over 10 miles from Essex center point would be filtered out.

What we would expect is to find anything 10 miles away from Essex outer borders.

Having an area stored for "Essex" containing its borders, allows us to combine `ST_Buffer` and `ST_DWithin` to first expand the area borders to cover the provided search radius, and then find if any vacancy location is contained within that expanded area.

### Mappings

Within the [mapping files](/config/data/ons_mappings/) we define the subset of cities, regions and counties we store polygon areas for. This is used by the [location data setup](/config/initializers/location_data.rb).

The [mapped locations file](/config/data/ons_mappings/mapped_locations.yml) helps to match common location search terms with an appropriate location polygon if any.

## Getting the geographical coordinates

As many location search terms don't match a polygon name, the service falls back to obtaining the location coordinates.

We use the [Geocoding class](/lib/geocoding.rb) to retrieve and cache the location coordinates. The default source for retrieving the location coordinates is the Google Geocoding API.

Information about the API usage/costs should be accessible from the Google Cloud panel using your DfE email account.

### Google Geocoding API costs

Google Geocoding API is one of our higher costs in Google Cloud.
To reduce the cost as much as possible, and as the coordinate info in the UK for a given point is quite stable data unlikely to change, we cache its responses for a long period, so there are fewer API hits renewing existing cached results.

Please be aware of the impact on the API costs if deciding to modify the Geocoding cache duration period.
