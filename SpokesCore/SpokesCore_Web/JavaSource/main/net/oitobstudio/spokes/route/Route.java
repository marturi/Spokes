package net.oitobstudio.spokes.route;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import net.oitobstudio.spokes.SpokesFault;

import org.apache.log4j.Logger;

import com.vividsolutions.jts.geom.Envelope;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.GeometryFactory;

public class Route {
	private static Logger log = Logger.getLogger(Route.class);
	private List<RouteSegment> routeSegments;
	private List<RouteLeg> routeLegs;
	private Map<String,Character> segmentTypeSequence;
	private double routeLength;
	private SpokesFault routeFault;
	private Envelope boundingBox;
	private GeometryFactory factory;

	public Route(){}

	public Route(List<RouteSegment> routeSegments, GeometryFactory factory){
		this.factory = factory;
		this.routeSegments = routeSegments;
		routeLegs = new ArrayList<RouteLeg>();
		segmentTypeSequence = new HashMap<String,Character>();
		initRoute();
	}

	public Route(SpokesFault routeFault){
		this.routeFault = routeFault;
	}

	public List<RouteLeg> getRouteLegs(){
		return routeLegs != null ? (Collections.unmodifiableList(routeLegs)) : null;
	}

	public double getRouteLength(){
		return (double)routeLength;
	}

	public Map<String,Character> getSegmentTypeSequence(){
		return segmentTypeSequence;
	}

	public SpokesFault getRouteFault() {
		return routeFault;
	}

	public double getMaxX() {
		double maxX = 0.0;
		Envelope bb = getBoundingBoxForRoute();
		if(bb != null) {
			maxX = bb.getMaxX();
		}
		return maxX;
	}

	public double getMinX() {
		double minX = 0.0;
		Envelope bb = getBoundingBoxForRoute();
		if(bb != null) {
			minX = bb.getMinX();
		}
		return minX;
	}

	public double getMaxY() {
		double maxY = 0.0;
		Envelope bb = getBoundingBoxForRoute();
		if(bb != null) {
			maxY = bb.getMaxY();
		}
		return maxY;
	}

	public double getMinY() {
		double minY = 0.0;
		Envelope bb = getBoundingBoxForRoute();
		if(bb != null) {
			minY = bb.getMinY();
		}
		return minY;
	}

	private Envelope getBoundingBoxForRoute() {
		if(boundingBox == null) {
			if(routeSegments != null && !routeSegments.isEmpty()) {
				List<Geometry> edges = new ArrayList<Geometry>();
				for(RouteSegment r : routeSegments){
					edges.add(r.getEdge());
				}
				boundingBox = factory.buildGeometry(edges).getEnvelopeInternal();
			}
		}
		return boundingBox;
	}

	private void initRoute(){
		int index = 0;
		int legIndex = 0;
		RouteLeg leg = null;
		for(RouteSegment r : routeSegments){
			if(!overlapsWithPrevSegment(index)){
				linkSegmentAndOrderSegmentPoints(r, index);
				if(isNewLeg(r)){
					leg = new RouteLeg(legIndex);
					routeLegs.add(leg);
					legIndex++;
				}
				routeLength += r.getLength();
				int uniqueCoordIndex = leg.addRouteSegement(r);
				if(uniqueCoordIndex > -1){
					addSegmentType(r, (leg.getIndex() + "_" + uniqueCoordIndex));
				}
			}
			index++;
		}
	}

	private boolean overlapsWithPrevSegment(int index){
		if(index > 0){
			RouteSegment currentRouteSegment = routeSegments.get(index);
			RouteSegment prevRouteSegment = routeSegments.get(index-1);
			if(currentRouteSegment.getSource() == prevRouteSegment.getSource() &&
					currentRouteSegment.getTarget() == prevRouteSegment.getTarget()){
				return true;
			}
		}
		return false;
	}

	private void addSegmentType(RouteSegment r, String uniqueCoordIndex){
		Character segType = r.getSegmentType();
		if(r.getPrevSegment() == null || !r.getPrevSegment().getSegmentType().equals(segType)){
			segmentTypeSequence.put(uniqueCoordIndex, segType);
		}
	}

	private void linkSegmentAndOrderSegmentPoints(RouteSegment r, int index){
		if(index+1 < routeSegments.size()){
			r.setNextSegment(routeSegments.get(index+1));
		}
		if(index > 0){
			r.setPrevSegment(routeSegments.get(index-1));
		}
		r.orderPoints();
	}

	private boolean isNewLeg(RouteSegment rs){
		boolean isNewLeg = true;
		RouteSegment prevSegment = rs.getPrevSegment();
		if(prevSegment != null){
			if(rs.getStreet().equalsIgnoreCase(prevSegment.getStreet())){
				isNewLeg = false;
			}
		}
		return isNewLeg;
	}
}
