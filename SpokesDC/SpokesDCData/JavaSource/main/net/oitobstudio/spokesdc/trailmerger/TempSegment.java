package net.oitobstudio.spokesdc.trailmerger;

import java.util.Map;

import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.LineString;
import com.vividsolutions.jts.noding.SegmentString;

@SuppressWarnings("unchecked")
public class TempSegment {
	private long id;
	private LineString edge;
	private String name;
	private Character bikeSegType;
	private String direction;

	public TempSegment(){};
	
	public TempSegment(SegmentString ss, GeometryFactory gf) {
		edge = gf.createLineString(ss.getCoordinates());
		Map<String,Object> data = (Map<String,Object>)ss.getData();
		name = (String)data.get("name");
		bikeSegType = (Character)data.get("bikeSegType");
		direction = (String)data.get("direction");
	}

	public LineString getEdge() {
		return edge;
	}

	public long getId() {
		return id;
	}

	public String getName() {
		return name;
	}

	public Character getBikeSegType() {
		return bikeSegType;
	}

	public String getDirection() {
		return direction;
	}
}
