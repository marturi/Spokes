package net.oitobstudio.spokesdc.street;

import net.oitobstudio.spokesdc.trailmerger.TempSegment;

import com.vividsolutions.jts.geom.LineString;

public class StreetSegment {
	private long id;
	private LineString edge;
	private String street;
	private Character bikeSegType;
	private String direction;

	public StreetSegment(){}
	
	public StreetSegment(TempSegment tempSegment) {
		edge = tempSegment.getEdge();
		street = tempSegment.getName();
		bikeSegType = tempSegment.getBikeSegType();
		direction = tempSegment.getDirection();
	}

	public long getId(){
		return id;
	}

	public LineString getEdge() {
		return edge;
	}

	public String getStreet() {
		return street;
	}

	public Character getBikeSegType() {
		return bikeSegType;
	}

	public String getDirection() {
		return direction;
	}
}