package net.oitobstudio.spokesdc.trail;

import com.vividsolutions.jts.geom.LineString;

public class TrailSegment {
	private long id;
	private LineString edge;
	private String name;

	public long getId(){
		return id;
	}

	public LineString getEdge() {
		return edge;
	}

	public String getName() {
		return name;
	}
}
