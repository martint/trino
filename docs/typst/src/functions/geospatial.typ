#import "/lib/trino-docs.typ": *

#anchor("doc-functions-geospatial")
= Geospatial functions

Trino Geospatial functions that begin with the #raw("ST_") prefix support the SQL\/MM specification and are compliant with the Open Geospatial Consortium’s \(OGC\) OpenGIS Specifications. As such, many Trino Geospatial functions require, or more accurately, assume that geometries that are operated on are both simple and valid. For example, it does not make sense to calculate the area of a polygon that has a hole defined outside the polygon, or to construct a polygon from a non-simple boundary line.

Trino Geospatial functions support the Well-Known Text \(WKT\) and Well-Known Binary \(WKB\) form of spatial objects:

- #raw("POINT (0 0)")
- #raw("LINESTRING (0 0, 1 1, 1 2)")
- #raw("POLYGON ((0 0, 4 0, 4 4, 0 4, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1))")
- #raw("MULTIPOINT (0 0, 1 2)")
- #raw("MULTILINESTRING ((0 0, 1 1, 1 2), (2 3, 3 2, 5 4))")
- #raw("MULTIPOLYGON (((0 0, 4 0, 4 4, 0 4, 0 0), (1 1, 2 1, 2 2, 1 2, 1 1)), ((-1 -1, -1 -2, -2 -2, -2 -1, -1 -1)))")
- #raw("GEOMETRYCOLLECTION (POINT(2 3), LINESTRING (2 3, 3 4))")

Use #link(label("fn-st-geometryfromtext"), raw("ST_GeometryFromText")) and #link(label("fn-st-geomfrombinary"), raw("ST_GeomFromBinary")) functions to create geometry objects from WKT or WKB.

The #raw("SphericalGeography") type provides native support for spatial features represented on #emph[geographic] coordinates \(sometimes called #emph[geodetic] coordinates, or #emph[lat\/lon], or #emph[lon\/lat]\). Geographic coordinates are spherical coordinates expressed in angular units \(degrees\).

The basis for the #raw("Geometry") type is a plane. The shortest path between two points on the plane is a straight line. That means calculations on geometries \(areas, distances, lengths, intersections, etc.\) can be calculated using cartesian mathematics and straight line vectors.

The basis for the #raw("SphericalGeography") type is a sphere. The shortest path between two points on the sphere is a great circle arc. That means that calculations on geographies \(areas, distances, lengths, intersections, etc.\) must be calculated on the sphere, using more complicated mathematics. More accurate measurements that take the actual spheroidal shape of the world into account are not supported.

Values returned by the measurement functions #link(label("fn-st-distance"), raw("ST_Distance")) and #link(label("fn-st-length"), raw("ST_Length")) are in the unit of meters; values returned by #link(label("fn-st-area"), raw("ST_Area")) are in square meters.

Use #link(label("fn-to-spherical-geography"), raw("to_spherical_geography()")) function to convert a geometry object to geography object.

For example, #raw("ST_Distance(ST_Point(-71.0882, 42.3607), ST_Point(-74.1197, 40.6976))") returns #raw("3.4577") in the unit of the passed-in values on the Euclidean plane, while #raw("ST_Distance(to_spherical_geography(ST_Point(-71.0882, 42.3607)), to_spherical_geography(ST_Point(-74.1197, 40.6976)))") returns #raw("312822.179") in meters.

== Constructors

#function-def("fn-st-asbinary", "ST_AsBinary(Geometry)", "varbinary")[
Returns the WKB representation of the geometry.
]

#function-def("fn-st-astext", "ST_AsText(Geometry)", "varchar")[
Returns the WKT representation of the geometry. For empty geometries, #raw("ST_AsText(ST_LineFromText('LINESTRING EMPTY'))") will produce #raw("'MULTILINESTRING EMPTY'") and #raw("ST_AsText(ST_Polygon('POLYGON EMPTY'))") will produce #raw("'MULTIPOLYGON EMPTY'").
]

#function-def("fn-st-geometryfromtext", "ST_GeometryFromText(varchar)", "Geometry")[
Returns a geometry type object from WKT representation.
]

#function-def("fn-st-geomfrombinary", "ST_GeomFromBinary(varbinary)", "Geometry")[
Returns a geometry type object from WKB or EWKB representation.
]

#function-def("fn-st-geomfromkml", "ST_GeomFromKML(varchar)", "Geometry")[
Returns a geometry type object from KML representation.
]

#function-def("fn-geometry-from-hadoop-shape", "geometry_from_hadoop_shape(varbinary)", "Geometry")[
Returns a geometry type object from Spatial Framework for Hadoop representation.
]

#function-def("fn-st-linefromtext", "ST_LineFromText(varchar)", "LineString")[
Returns a geometry type linestring object from WKT representation.
]

#function-def("fn-st-linestring", "ST_LineString(array(Point))", "LineString")[
Returns a LineString formed from an array of points. If there are fewer than two non-empty points in the input array, an empty LineString will be returned. Array elements must not be #raw("NULL") or the same as the previous element. The returned geometry may not be simple, e.g. may self-intersect or may contain duplicate vertexes depending on the input.
]

#function-def("fn-st-multipoint", "ST_MultiPoint(array(Point))", "MultiPoint")[
Returns a MultiPoint geometry object formed from the specified points. Returns #raw("NULL") if input array is empty. Array elements must not be #raw("NULL") or empty. The returned geometry may not be simple and may contain duplicate points if input array has duplicates.
]

#function-def("fn-st-point", "ST_Point(lon: double, lat: double)", "Point")[
Returns a geometry type point object with the given coordinate values.
]

#function-def("fn-st-polygon", "ST_Polygon(varchar)", "Polygon")[
Returns a geometry type polygon object from WKT representation.
]

#function-def("fn-to-spherical-geography", "to_spherical_geography(Geometry)", "SphericalGeography")[
Converts a Geometry object to a SphericalGeography object on the sphere of the Earth's radius. This function is only applicable to #raw("POINT"), #raw("MULTIPOINT"), #raw("LINESTRING"), #raw("MULTILINESTRING"), #raw("POLYGON"), #raw("MULTIPOLYGON") geometries defined in 2D space, or #raw("GEOMETRYCOLLECTION") of such geometries. For each point of the input geometry, it verifies that #raw("point.x") is within #raw("[-180.0, 180.0]") and #raw("point.y") is within #raw("[-90.0, 90.0]"), and uses them as \(longitude, latitude\) degrees to construct the shape of the #raw("SphericalGeography") result.
]

#function-def("fn-to-geometry", "to_geometry(SphericalGeography)", "Geometry")[
Converts a SphericalGeography object to a Geometry object.
]

== Relationship tests

#function-def("fn-st-contains", "ST_Contains(geometryA: Geometry, geometryB: Geometry)", "boolean")[
Returns #raw("true") if and only if no points of the second geometry lie in the exterior of the first geometry, and at least one point of the interior of the first geometry lies in the interior of the second geometry.
]

#function-def("fn-st-crosses", "ST_Crosses(first: Geometry, second: Geometry)", "boolean")[
Returns #raw("true") if the supplied geometries have some, but not all, interior points in common.
]

#function-def("fn-st-disjoint", "ST_Disjoint(first: Geometry, second: Geometry)", "boolean")[
Returns #raw("true") if the give geometries do not #emph[spatially intersect] -- if they do not share any space together.
]

#function-def("fn-st-equals", "ST_Equals(first: Geometry, second: Geometry)", "boolean")[
Returns #raw("true") if the given geometries represent the same geometry.
]

#function-def("fn-st-intersects", "ST_Intersects(first: Geometry, second: Geometry)", "boolean")[
Returns #raw("true") if the given geometries spatially intersect in two dimensions \(share any portion of space\) and #raw("false") if they do not \(they are disjoint\).
]

#function-def("fn-st-overlaps", "ST_Overlaps(first: Geometry, second: Geometry)", "boolean")[
Returns #raw("true") if the given geometries share space, are of the same dimension, but are not completely contained by each other.
]

#function-def("fn-st-relate", "ST_Relate(first: Geometry, second: Geometry)", "boolean")[
Returns #raw("true") if first geometry is spatially related to second geometry.
]

#function-def("fn-st-touches", "ST_Touches(first: Geometry, second: Geometry)", "boolean")[
Returns #raw("true") if the given geometries have at least one point in common, but their interiors do not intersect.
]

#function-def("fn-st-within", "ST_Within(first: Geometry, second: Geometry)", "boolean")[
Returns #raw("true") if first geometry is completely inside second geometry.
]

== Operations

#function-def("fn-geometry-nearest-points", "geometry_nearest_points(first: Geometry, second: Geometry)", "row(Point, Point)")[
Returns the points on each geometry nearest the other.  If either geometry is empty, return #raw("NULL").  Otherwise, return a row of two Points that have the minimum distance of any two points on the geometries.  The first Point will be from the first Geometry argument, the second from the second Geometry argument.  If there are multiple pairs with the minimum distance, one pair is chosen arbitrarily.
]

#function-def("fn-geometry-union", "geometry_union(array(Geometry))", "Geometry")[
Returns a geometry that represents the point set union of the input geometries. Performance of this function, in conjunction with #link(label("fn-array-agg"), raw("array_agg")) to first aggregate the input geometries, may be better than #link(label("fn-geometry-union-agg"), raw("geometry_union_agg")), at the expense of higher memory utilization.
]

#function-def("fn-st-boundary", "ST_Boundary(Geometry)", "Geometry")[
Returns the closure of the combinatorial boundary of this geometry.
]

#function-def("fn-st-buffer", "ST_Buffer(Geometry, distance)", "Geometry")[
Returns the geometry that represents all points whose distance from the specified geometry is less than or equal to the specified distance. If the points of the geometry are extremely close together \(#raw("delta < 1e-8")\), this might return an empty geometry.
]

#function-def("fn-st-difference", "ST_Difference(first: Geometry, second: Geometry)", "Geometry")[
Returns the geometry value that represents the point set difference of the given geometries.
]

#function-def("fn-st-envelope", "ST_Envelope(Geometry)", "Geometry")[
Returns the bounding rectangular polygon of a geometry.
]

#function-def("fn-st-envelopeaspts", "ST_EnvelopeAsPts(Geometry)", "array(Geometry)")[
Returns an array of two points: the lower left and upper right corners of the bounding rectangular polygon of a geometry. Returns #raw("NULL") if input geometry is empty.
]

#function-def("fn-st-exteriorring", "ST_ExteriorRing(Geometry)", "Geometry")[
Returns a line string representing the exterior ring of the input polygon.
]

#function-def("fn-st-intersection", "ST_Intersection(first: Geometry, second: Geometry)", "Geometry")[
Returns the geometry value that represents the point set intersection of two geometries.
]

#function-def("fn-st-symdifference", "ST_SymDifference(first: Geometry, second: Geometry)", "Geometry")[
Returns the geometry value that represents the point set symmetric difference of two geometries.
]

#function-def("fn-st-union", "ST_Union(first: Geometry, second: Geometry)", "Geometry")[
Returns a geometry that represents the point set union of the input geometries.

See also:  #link(label("fn-geometry-union"), raw("geometry_union")), #link(label("fn-geometry-union-agg"), raw("geometry_union_agg"))
]

== Accessors

#function-def("fn-st-area", "ST_Area(Geometry)", "double")[
Returns the 2D Euclidean area of a geometry.

For Point and LineString types, returns 0.0. For GeometryCollection types, returns the sum of the areas of the individual geometries.
]

#function-def("fn-st-area-2", "ST_Area(SphericalGeography)", "double", ref: false)[
Returns the area of a polygon or multi-polygon in square meters using a spherical model for Earth.
]

#function-def("fn-st-centroid", "ST_Centroid(Geometry)", "Geometry")[
Returns the point value that is the mathematical centroid of a geometry.
]

#function-def("fn-st-convexhull", "ST_ConvexHull(Geometry)", "Geometry")[
Returns the minimum convex geometry that encloses all input geometries.
]

#function-def("fn-st-coorddim", "ST_CoordDim(Geometry)", "bigint")[
Returns the coordinate dimension of the geometry.
]

#function-def("fn-st-dimension", "ST_Dimension(Geometry)", "bigint")[
Returns the inherent dimension of this geometry object, which must be less than or equal to the coordinate dimension.
]

#function-def("fn-st-distance", "ST_Distance(first: Geometry, second: Geometry)", "double")[
Returns the 2-dimensional cartesian minimum distance \(based on spatial ref\) between two geometries in projected units.
]

#function-def("fn-st-distance-2", "ST_Distance(first: SphericalGeography, second: SphericalGeography)", "double", ref: false)[
Returns the great-circle distance in meters between two SphericalGeography points.
]

#function-def("fn-st-geometryn", "ST_GeometryN(Geometry, index)", "Geometry")[
Returns the geometry element at a given index \(indices start at 1\). If the geometry is a collection of geometries \(e.g., GEOMETRYCOLLECTION or MULTI\*\), returns the geometry at a given index. If the given index is less than 1 or greater than the total number of elements in the collection, returns #raw("NULL"). Use #link(label("fn-st-numgeometries"), raw("ST_NumGeometries")) to find out the total number of elements. Singular geometries \(e.g., POINT, LINESTRING, POLYGON\), are treated as collections of one element. Empty geometries are treated as empty collections.
]

#function-def("fn-st-interiorringn", "ST_InteriorRingN(Geometry, index)", "Geometry")[
Returns the interior ring element at the specified index \(indices start at 1\). If the given index is less than 1 or greater than the total number of interior rings in the input geometry, returns #raw("NULL"). The input geometry must be a polygon. Use #link(label("fn-st-numinteriorring"), raw("ST_NumInteriorRing")) to find out the total number of elements.
]

#function-def("fn-st-geometrytype", "ST_GeometryType(Geometry)", "varchar")[
Returns the type of the geometry.
]

#function-def("fn-st-isclosed", "ST_IsClosed(Geometry)", "boolean")[
Returns #raw("true") if the linestring's start and end points are coincident.
]

#function-def("fn-st-isempty", "ST_IsEmpty(Geometry)", "boolean")[
Returns #raw("true") if this Geometry is an empty geometrycollection, polygon, point etc.
]

#function-def("fn-st-issimple", "ST_IsSimple(Geometry)", "boolean")[
Returns #raw("true") if this Geometry has no anomalous geometric points, such as self intersection or self tangency.
]

#function-def("fn-st-isring", "ST_IsRing(Geometry)", "boolean")[
Returns #raw("true") if and only if the line is closed and simple.
]

#function-def("fn-st-isvalid", "ST_IsValid(Geometry)", "boolean")[
Returns #raw("true") if and only if the input geometry is well-formed. Use #link(label("fn-geometry-invalid-reason"), raw("geometry_invalid_reason")) to determine why the geometry is not well-formed.
]

#function-def("fn-st-length", "ST_Length(Geometry)", "double")[
Returns the length of a linestring or multi-linestring using Euclidean measurement on a two-dimensional plane \(based on spatial ref\) in projected units.
]

#function-def("fn-st-length-2", "ST_Length(SphericalGeography)", "double", ref: false)[
Returns the length of a linestring or multi-linestring on a spherical model of the Earth. This is equivalent to the sum of great-circle distances between adjacent points on the linestring.
]

#function-def("fn-st-pointn", "ST_PointN(LineString, index)", "Point")[
Returns the vertex of a linestring at a given index \(indices start at 1\). If the given index is less than 1 or greater than the total number of elements in the collection, returns #raw("NULL"). Use #link(label("fn-st-numpoints"), raw("ST_NumPoints")) to find out the total number of elements.
]

#function-def("fn-st-points", "ST_Points(Geometry)", "array(Point)")[
Returns an array of points in a linestring.
]

#function-def("fn-st-xmax", "ST_XMax(Geometry)", "double")[
Returns X maxima of a bounding box of a geometry.
]

#function-def("fn-st-ymax", "ST_YMax(Geometry)", "double")[
Returns Y maxima of a bounding box of a geometry.
]

#function-def("fn-st-xmin", "ST_XMin(Geometry)", "double")[
Returns X minima of a bounding box of a geometry.
]

#function-def("fn-st-ymin", "ST_YMin(Geometry)", "double")[
Returns Y minima of a bounding box of a geometry.
]

#function-def("fn-st-startpoint", "ST_StartPoint(Geometry)", "point")[
Returns the first point of a LineString geometry as a Point. This is a shortcut for #raw("ST_PointN(geometry, 1)").
]

#function-def("fn-simplify-geometry", "simplify_geometry(Geometry, double)", "Geometry")[
Returns a "simplified" version of the input geometry using the Douglas-Peucker algorithm. Will avoid creating derived geometries \(polygons in particular\) that are invalid.
]

#function-def("fn-st-endpoint", "ST_EndPoint(Geometry)", "point")[
Returns the last point of a LineString geometry as a Point. This is a shortcut for #raw("ST_PointN(geometry, ST_NumPoints(geometry))").
]

#function-def("fn-st-x", "ST_X(Point)", "double")[
Returns the X coordinate of the point.
]

#function-def("fn-st-y", "ST_Y(Point)", "double")[
Returns the Y coordinate of the point.
]

#function-def("fn-st-interiorrings", "ST_InteriorRings(Geometry)", "array(Geometry)")[
Returns an array of all interior rings found in the input geometry, or an empty array if the polygon has no interior rings. Returns #raw("NULL") if the input geometry is empty. The input geometry must be a polygon.
]

#function-def("fn-st-numgeometries", "ST_NumGeometries(Geometry)", "bigint")[
Returns the number of geometries in the collection. If the geometry is a collection of geometries \(e.g., GEOMETRYCOLLECTION or MULTI\*\), returns the number of geometries, for single geometries returns 1, for empty geometries returns 0.
]

#function-def("fn-st-geometries", "ST_Geometries(Geometry)", "array(Geometry)")[
Returns an array of geometries in the specified collection. Returns a one-element array if the input geometry is not a multi-geometry. Returns #raw("NULL") if input geometry is empty.
]

#function-def("fn-st-numpoints", "ST_NumPoints(Geometry)", "bigint")[
Returns the number of points in a geometry. This is an extension to the SQL\/MM #raw("ST_NumPoints") function which only applies to point and linestring.
]

#function-def("fn-st-numinteriorring", "ST_NumInteriorRing(Geometry)", "bigint")[
Returns the cardinality of the collection of interior rings of a polygon.
]

#function-def("fn-line-interpolate-point", "line_interpolate_point(LineString, double)", "Geometry")[
Returns a Point interpolated along a LineString at the fraction given. The fraction must be between 0 and 1, inclusive.
]

#function-def("fn-line-interpolate-points", "line_interpolate_points(LineString, double, repeated)", "array(Geometry)")[
Returns an array of Points interpolated along a LineString. The fraction must be between 0 and 1, inclusive.
]

#function-def("fn-line-locate-point", "line_locate_point(LineString, Point)", "double")[
Returns a float between 0 and 1 representing the location of the closest point on the LineString to the given Point, as a fraction of total 2d line length.

Returns #raw("NULL") if a LineString or a Point is empty or #raw("NULL").
]

#function-def("fn-geometry-invalid-reason", "geometry_invalid_reason(Geometry)", "varchar")[
Returns the reason for why the input geometry is not valid. Returns #raw("NULL") if the input is valid.
]

#function-def("fn-great-circle-distance", "great_circle_distance(latitude1, longitude1, latitude2, longitude2)", "double")[
Returns the great-circle distance between two points on Earth's surface in kilometers.
]

#function-def("fn-to-geojson-geometry", "to_geojson_geometry(SphericalGeography)", "varchar")[
Returns the GeoJSON encoded defined by the input spherical geography.
]

#function-def("fn-from-geojson-geometry", "from_geojson_geometry(varchar)", "SphericalGeography")[
Returns the spherical geography type object from the GeoJSON representation stripping non geometry key\/values. Feature and FeatureCollection are not supported.
]

== Aggregations

#function-def("fn-convex-hull-agg", "convex_hull_agg(Geometry)", "Geometry")[
Returns the minimum convex geometry that encloses all input geometries.
]

#function-def("fn-geometry-union-agg", "geometry_union_agg(Geometry)", "Geometry")[
Returns a geometry that represents the point set union of all input geometries.
]

== Bing tiles

These functions convert between geometries and #link("https://msdn.microsoft.com/library/bb259689.aspx")[Bing tiles].

#function-def("fn-bing-tile", "bing_tile(x, y, zoom_level)", "BingTile")[
Creates a Bing tile object from XY coordinates and a zoom level. Zoom levels from 1 to 23 are supported.
]

#function-def("fn-bing-tile-2", "bing_tile(quadKey)", "BingTile", ref: false)[
Creates a Bing tile object from a quadkey.
]

#function-def("fn-bing-tile-at", "bing_tile_at(latitude, longitude, zoom_level)", "BingTile")[
Returns a Bing tile at a given zoom level containing a point at a given latitude and longitude. Latitude must be within #raw("[-85.05112878, 85.05112878]") range. Longitude must be within #raw("[-180, 180]") range. Zoom levels from 1 to 23 are supported.
]

#function-def("fn-bing-tiles-around", "bing_tiles_around(latitude, longitude, zoom_level)", "array(BingTile)")[
Returns a collection of Bing tiles that surround the point specified by the latitude and longitude arguments at a given zoom level.
]

#function-def("fn-bing-tiles-around-2", "bing_tiles_around(latitude, longitude, zoom_level, radius_in_km)", "array(BingTile)", ref: false)[
Returns a minimum set of Bing tiles at specified zoom level that cover a circle of specified radius in km around a specified \(latitude, longitude\) point.
]

#function-def("fn-bing-tile-coordinates", "bing_tile_coordinates(tile)", "row<x, y>")[
Returns the XY coordinates of a given Bing tile.
]

#function-def("fn-bing-tile-polygon", "bing_tile_polygon(tile)", "Geometry")[
Returns the polygon representation of a given Bing tile.
]

#function-def("fn-bing-tile-quadkey", "bing_tile_quadkey(tile)", "varchar")[
Returns the quadkey of a given Bing tile.
]

#function-def("fn-bing-tile-zoom-level", "bing_tile_zoom_level(tile)", "tinyint")[
Returns the zoom level of a given Bing tile.
]

#function-def("fn-geometry-to-bing-tiles", "geometry_to_bing_tiles(geometry, zoom_level)", "array(BingTile)")[
Returns the minimum set of Bing tiles that fully covers a given geometry at a given zoom level. Zoom levels from 1 to 23 are supported.
]

== Encoded polylines

These functions convert between geometries and #link("https://developers.google.com/maps/documentation/utilities/polylinealgorithm")[encoded polylines].

#function-def("fn-to-encoded-polyline", "to_encoded_polyline(Geometry)", "varchar")[
Encodes a linestring or multipoint to a polyline.
]

#function-def("fn-from-encoded-polyline", "from_encoded_polyline(varchar)", "Geometry")[
Decodes a polyline to a linestring.
]
