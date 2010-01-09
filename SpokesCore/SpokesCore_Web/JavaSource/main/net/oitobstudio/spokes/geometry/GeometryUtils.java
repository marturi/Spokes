package net.oitobstudio.spokes.geometry;

import com.vividsolutions.jts.geom.Coordinate;

public class GeometryUtils {
	public static Coordinate parseCoordinate(String coordinateStr){
		Coordinate c = null;
		if(coordinateStr != null){
			String[] xy = coordinateStr.split(",");
			if(xy.length == 2){
				c = new Coordinate(Double.parseDouble(xy[0].trim()), Double.parseDouble(xy[1].trim()));
			}
		}
		return c;
	}
}