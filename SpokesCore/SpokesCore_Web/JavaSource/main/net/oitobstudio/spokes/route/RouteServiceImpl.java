package net.oitobstudio.spokes.route;

import java.util.List;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.geometry.BoundingBoxRepository;

import org.apache.log4j.Logger;

import com.vividsolutions.jts.geom.Point;
import com.vividsolutions.jts.geom.GeometryFactory;

public class RouteServiceImpl implements RouteService {
	private static Logger log = Logger.getLogger(RouteServiceImpl.class);
	private GeometryFactory geometryFactory;
	private RouteSegmentRepository routeSegmentRepository;
	private BoundingBoxRepository boundingBoxRepository;

	public Route getShortestPathRoute(RouteCriteria routeCriteria) throws SpokesException {
		routeCriteria.validateRouteCriteria(boundingBoxRepository.findGlobalBoundingBox(), geometryFactory);
		Point startPoint = geometryFactory.createPoint(routeCriteria.getStartPoint());
		Point endPoint = geometryFactory.createPoint(routeCriteria.getEndPoint());
		List<BookendRouteSegment> startEdges = routeSegmentRepository.findClosestEdges(startPoint.getCoordinate());
		List<BookendRouteSegment> endEdges = routeSegmentRepository.findClosestEdges(endPoint.getCoordinate());
		if(startEdges == null || endEdges == null){
			int exType = ClosestEdgeNotFoundException.END;
			String badCoord = endPoint.getCoordinate().toString();
			if(startEdges == null){
				exType = ClosestEdgeNotFoundException.START;
				badCoord = startPoint.getCoordinate().toString();
			}
			throw new ClosestEdgeNotFoundException("No street found near coord " + badCoord, exType);
		}
		List<RouteSegment> spSegments = routeSegmentRepository.findShortestPathRoute(startEdges.get(0), endEdges.get(0), routeCriteria.getOptions());
		Route spRoute = new Route(spSegments, geometryFactory);
		return spRoute;
	}

	public void setRouteSegmentRepository(RouteSegmentRepository routeSegmentRepository){
		this.routeSegmentRepository = routeSegmentRepository;
	}

	public void setBoundingBoxRepository(BoundingBoxRepository boundingBoxRepository) {
		this.boundingBoxRepository = boundingBoxRepository;
	}

	public void setGeometryFactory(GeometryFactory geometryFactory){
		this.geometryFactory = geometryFactory;
	}
}