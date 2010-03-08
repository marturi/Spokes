package net.oitobstudio.spokes.route;

import java.util.List;
import java.util.ArrayList;

import com.vividsolutions.jts.algorithm.Angle;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.Point;
import com.vividsolutions.jts.geom.LineString;
import com.vividsolutions.jts.linearref.LocationIndexedLine;
import com.vividsolutions.jts.linearref.LinearLocation;

public class BookendRouteSegment extends RouteSegment {
	private Point onGraphPoint;
	private Point onGraphPointReprojected;
	private LineString edgeReprojected;
	private LineString trimmedEdge;
	private RouteSegment nearestNeighbor;
	private String accuracyLevel;
	private boolean isStartEdge;

	public static final String UNKNOWN 		= "0";
	public static final String COUNTRY 		= "1";
	public static final String REGION 		= "2";
	public static final String SUBREGION 	= "3";
	public static final String TOWN 		= "4";
	public static final String POSTAL_CODE 	= "5";
	public static final String STREET 		= "6";
	public static final String INTERSECTION	= "7";
	public static final String ADDRESS 		= "8";
	public static final String PREMISE 		= "9";

	public Point getOnGraphPoint() {
		return onGraphPoint;
	}

	void setStartEdge(boolean isStartEdge) {
		this.isStartEdge = isStartEdge;
	}

	public boolean isStartEdge(){
		return isStartEdge;
	}

	void setAccuracyLevel(String accuracyLevel) {
		this.accuracyLevel = accuracyLevel;
	}

	private boolean isIntersection(){
		if(accuracyLevel != null && accuracyLevel.equals(INTERSECTION)){
			return true;
		}else if(onGraphPointReprojected.isWithinDistance(edgeReprojected.getStartPoint(), 2) ||
				onGraphPointReprojected.isWithinDistance(edgeReprojected.getEndPoint(), 2)) {
			return true;
		}
		return false;
	}

	public double distanceFromVertex(){
		return Math.min(onGraphPointReprojected.distance(edgeReprojected.getStartPoint()),
				onGraphPointReprojected.distance(edgeReprojected.getEndPoint()));
	}

	public int getStartOrEndVertex(){
		int startOrEndVertex = isStartEdge() ? getTarget() : getSource();
		if(isIntersection() && nearestNeighbor != null){
			if(getSource() == nearestNeighbor.getSource() ||
					getSource() == nearestNeighbor.getTarget()){
				startOrEndVertex = getSource();
			} else if(getTarget() == nearestNeighbor.getSource() ||
					getTarget() == nearestNeighbor.getTarget()){
				startOrEndVertex = getTarget();
			}
		}
		return startOrEndVertex;
	}

	public void gobbleSegment(RouteSegment gobbledSegment) {
		this.id = gobbledSegment.id;
		this.edge = gobbledSegment.edge;
		this.segmentType = gobbledSegment.segmentType;
		this.street = gobbledSegment.street;
		this.source = gobbledSegment.source;
		this.target = gobbledSegment.target;
		this.prevSegment = gobbledSegment.prevSegment;
		this.nextSegment = gobbledSegment.nextSegment;
	}

	public double getLength(){
		float length = 0;
		Coordinate[] coords = getCoordinateSequence();
		if(coords != null){
			for(int i=0; i<coords.length; i++){
				if((i+1) < coords.length){
					length += distFrom((float)coords[i].y, (float)coords[i].x, (float)coords[i+1].y, (float)coords[i+1].x);
				}
			}
		}else{
			return super.getLength();
		}
		return (double)length;
	}

	public Coordinate[] getCoordinateSequence(){
		List<Coordinate> coordCollection = new ArrayList<Coordinate>();
		Coordinate[] coords = null;
		LineString te = getTrimmedEdge();
		if(te != null){
			coords = te.getCoordinates();
			for(Coordinate c : coords){
				coordCollection.add(c);
			}
			return coordCollection.toArray(new Coordinate[coordCollection.size()]);
		}else{
			return super.getCoordinateSequence();
		}
	}

	public LineString getEdge(){
		LineString trimmedEdge = getTrimmedEdge();
		if(trimmedEdge != null){
			return trimmedEdge;
		}else{
			return super.getEdge();
		}
	}

	private LineString getTrimmedEdge(){
		if(trimmedEdge == null){
			LocationIndexedLine indexedLine = new LocationIndexedLine(super.getEdge());
			LinearLocation startPointLocation = null;
			LinearLocation endPointLocation = null;
			if(isStartEdge()){
				if(getNextSegment() != null){
					Geometry intersection = super.getEdge().intersection(getNextSegment().getEdge());
					if(intersection != null){
						startPointLocation = indexedLine.indexOf(onGraphPoint.getCoordinate());
						Point centroid = intersection.getCentroid();
						if(centroid != null) {
							Coordinate endPointCoordinate = centroid.getCoordinate();
							if(intersection instanceof LineString){
								double distS = onGraphPoint.distance(((LineString) intersection).getStartPoint());
								double distE = onGraphPoint.distance(((LineString) intersection).getEndPoint());
								endPointCoordinate = distS > distE ? ((LineString)intersection).getStartPoint().getCoordinate() :
									((LineString)intersection).getEndPoint().getCoordinate();
							}
							endPointLocation = indexedLine.indexOf(endPointCoordinate);
						}
					}
				}
			}else{
				if(getPrevSegment() != null){
					Geometry intersection = super.getEdge().intersection(getPrevSegment().getEdge());
					if(intersection != null){
						endPointLocation = indexedLine.indexOf(onGraphPoint.getCoordinate());
						Point centroid = intersection.getCentroid();
						if(centroid != null){
							Coordinate startPointCoordinate = centroid.getCoordinate();
							if(intersection instanceof LineString){
								double distS = onGraphPoint.distance(((LineString) intersection).getStartPoint());
								double distE = onGraphPoint.distance(((LineString) intersection).getEndPoint());
								startPointCoordinate = distS > distE ? ((LineString)intersection).getStartPoint().getCoordinate() :
									((LineString)intersection).getEndPoint().getCoordinate();
							}
							startPointLocation = indexedLine.indexOf(startPointCoordinate);
						}
					}
				}
			}
			if(startPointLocation != null && endPointLocation != null){
				trimmedEdge = (LineString)indexedLine.extractLine(startPointLocation, endPointLocation);
			}
		}
		return trimmedEdge;
	}

	public void setNearestNeighbor(RouteSegment nearestNeighbor) {
		this.nearestNeighbor = nearestNeighbor;
	}

	public String getHeading(){
		double degrees = Angle.toDegrees(getAngle());
		if(degrees >= 80 && degrees <= 100){
			return "north";
		}else if(degrees >= -100 && degrees <= -80){
			return "south";
		}else if((degrees >= -180 && degrees <= -170) || (degrees >= 170 && degrees <= 180)){
			return "west";
		}else if(degrees >= -10 && degrees <= 10){
			return "east";
		}else if(degrees >= 11 && degrees <= 79){
			return "northeast";
		}else if(degrees >= -79 && degrees <= -11){
			return "southeast";
		}else if(degrees >= -179 && degrees <= -101){
			return "southwest";
		}else{
			return "northwest";
		}
	}

	private float distFrom(float lat1, float lng1, float lat2, float lng2) {
	    double earthRadius = 3958.75;
	    double dLat = Math.toRadians(lat2-lat1);
	    double dLng = Math.toRadians(lng2-lng1);
	    double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
	               Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
	               Math.sin(dLng/2) * Math.sin(dLng/2);
	    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
	    double dist = earthRadius * c;

	    int meterConversion = 1609;

	    return new Float(dist * meterConversion).floatValue();
	}
}