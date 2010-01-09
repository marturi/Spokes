package net.oitobstudio.spokes.shop;

import java.util.Map;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.MissingInputException;
import net.oitobstudio.spokes.geometry.BoundingBox;
import net.oitobstudio.spokes.geometry.GeometryUtils;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.LinearRing;

public class BikeShopCriteria {
	private String topLeft;
	private String bottomRight;
	private LinearRing boundingBox;
	private Map<String,String> options;

	public BikeShopCriteria(String topLeft, String bottomRight, Map<String,String> options){
		this.topLeft = topLeft;
		this.bottomRight = bottomRight;
		this.options = options;
	}

	public void validateBikeShopCriteria(GeometryFactory geometryFactory) throws SpokesException{
		if(getBoundingBox(geometryFactory) == null){
			throw new MissingInputException("The required input for finding the nearest bike shops is missing.  Please try again.");
		}
	}

	public LinearRing getBoundingBox(GeometryFactory geometryFactory) {
		if(boundingBox == null){
			Coordinate tl = GeometryUtils.parseCoordinate(topLeft);
			Coordinate br = GeometryUtils.parseCoordinate(bottomRight);
			boundingBox = BoundingBox.makeBoundingBox(geometryFactory, tl, br);
		}
		return boundingBox;
	}

	public Map<String, String> getOptions() {
		return options;
	}
}