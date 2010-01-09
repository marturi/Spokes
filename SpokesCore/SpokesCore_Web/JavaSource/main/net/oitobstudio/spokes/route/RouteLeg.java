package net.oitobstudio.spokes.route;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.vividsolutions.jts.geom.Coordinate;

public class RouteLeg {
	private List<RouteSegment> routeSegments;
	private StringBuffer coordinateSequence;
	private double length;
	private String street;
	private int index;
	private List<Coordinate> uniqueCoords;

	public RouteLeg() {}

	public RouteLeg(int index) {
		this.routeSegments = new ArrayList<RouteSegment>();
		this.index = index;
		this.coordinateSequence = new StringBuffer();
		this.uniqueCoords = new ArrayList<Coordinate>();
	}

	private void appendCoordinates(StringBuffer sb, RouteSegment r){
		Coordinate[] cSeq = r.getCoordinateSequence();
		for(Coordinate c : cSeq){
			if(!uniqueCoords.contains(c)){
				sb.append(c.x).append(",").append(c.y).append(" ");
				uniqueCoords.add(c);
			}
		}
	}

	public double getLength(){
		return (int)length;
	}

	public String getStreet(){
		return street;
	}

	public String getCoordinateSequence(){
		return coordinateSequence.toString().trim();
	}

	public int getIndex() {
		return index;
	}

	public String getTurn(){
		RouteSegment firstSegment = routeSegments.get(0);
		if(firstSegment instanceof BookendRouteSegment && index == 0){
			return ((BookendRouteSegment)firstSegment).getHeading();
		}else{
			return firstSegment.getTurn();
		}
	}

	public List<RouteSegment> getRouteSegments(){
		return Collections.unmodifiableList(routeSegments);
	}

	int addRouteSegement(RouteSegment routeSegment){
		int chgIndex = -1;
		if(!routeSegments.contains(routeSegment)){
			routeSegments.add(routeSegment);
			chgIndex = uniqueCoords.size() > 0 ? (uniqueCoords.size()-1) : 0;
			appendCoordinates(coordinateSequence, routeSegment);
			length += routeSegment.getLength();
			if(street == null){
				street = routeSegment.getStreet();
			}
			return chgIndex;
		}
		return chgIndex;
	}

	@Override
	public boolean equals(Object obj) {
		return ((RouteLeg)obj).index == index;
	}
}
