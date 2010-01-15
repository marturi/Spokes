package net.oitobstudio.spokes.route;

import java.util.List;
import java.util.Map;

import com.vividsolutions.jts.geom.Coordinate;

public interface RouteSegmentRepository {
	public List<BookendRouteSegment> findClosestEdges(Coordinate coordinate);
	public List<RouteSegment> findShortestPathRoute(BookendRouteSegment startEdge, BookendRouteSegment endEdge, Map<String,String> options);
}