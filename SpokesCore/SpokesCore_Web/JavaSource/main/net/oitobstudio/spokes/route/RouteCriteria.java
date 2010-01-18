package net.oitobstudio.spokes.route;

import java.util.Map;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.MissingInputException;
import net.oitobstudio.spokes.PointOutOfBoundsException;
import net.oitobstudio.spokes.geometry.BoundingBox;
import net.oitobstudio.spokes.geometry.GeometryUtils;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;

public class RouteCriteria {
	private String startPtStr;
	private String endPtStr;
	private Coordinate startPt;
	private Coordinate endPt;
	private Map<String,String> options;
	private String startPointAccuracyLevel;
	private String endPointAccuracyLevel;

	public RouteCriteria(String startPtStr, String endPtStr, Map<String,String> options){
		parsePoint(startPtStr, true);
		parsePoint(endPtStr, false);
		this.options = options;
	}

	private void parsePoint(String pointString, boolean isStartPoint){
		boolean hasAccuracyLevel = pointString.indexOf("(") > -1;
		String accuracyLevel = null;
		String ptString = pointString;
		if(hasAccuracyLevel){
			accuracyLevel = pointString.substring(pointString.indexOf("(")+1, pointString.indexOf(")"));
			ptString = pointString.substring(0, pointString.indexOf("("));
		}
		if(isStartPoint){
			this.startPtStr = ptString;
			this.startPointAccuracyLevel = accuracyLevel;
		}else{
			this.endPtStr = ptString;
			this.endPointAccuracyLevel = accuracyLevel;
		}
	}

	public String getStartPointAccuracyLevel() {
		return this.startPointAccuracyLevel;
	}

	public String getEndPointAccuracyLevel() {
		return this.endPointAccuracyLevel;
	}

	public Coordinate getStartPoint(){
		if(startPt == null){
			startPt = GeometryUtils.parseCoordinate(startPtStr);
		}
		return startPt;
	}

	public Coordinate getEndPoint(){
		if(endPt == null){
			endPt = GeometryUtils.parseCoordinate(endPtStr);
		}
		return endPt;
	}

	public Map<String, String> getOptions() {
		return options;
	}

	public void validateRouteCriteria(BoundingBox bBox, GeometryFactory geometryFactory) throws SpokesException{
		if(getStartPoint() == null || getEndPoint() == null){
			throw new MissingInputException("The required input for creating the route is missing.  Please try again.");
		}else if(!BoundingBox.isPointInBoundingBox(geometryFactory, startPt, bBox)){
			throw new PointOutOfBoundsException("Start point outside of bounding coordinates " + startPt, 
					"The start address entered is outside of city limits.");
		}else if(!BoundingBox.isPointInBoundingBox(geometryFactory, endPt, bBox)){
			throw new PointOutOfBoundsException("End point outside of bounding coordinates " + endPt, 
					"The end address entered is outside of city limits.");
		}
	}
}