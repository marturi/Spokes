package net.oitobstudio.spokes.route;

import com.vividsolutions.jts.geom.LineString;
import com.vividsolutions.jts.geom.Point;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.algorithm.Angle;

public class RouteSegment {
	protected long id;
	protected LineString edge;
	protected Character segmentType;
	protected String street;
	protected int source;
	protected int target;
	protected double length;
	protected RouteSegment prevSegment;
	protected RouteSegment nextSegment;

	public long getId(){
		return id;
	}

	public LineString getEdge() {
		return edge;
	}

	public Character getSegmentType() {
		return segmentType == null ? ' ' : segmentType;
	}

	public String getStreet(){
		return street;
	}

	public int getSource() {
		return source;
	}

	public int getTarget() {
		return target;
	}

	public double getLength() {
		return length;
	}

	public double getAngle(){
		if((int)length == 0 && prevSegment != null){
			return prevSegment.getAngle();
		}
		double radians = Angle.angle(edge.getStartPoint().getCoordinate(), edge.getEndPoint().getCoordinate());
		return radians;
	}

	public String getTurn(){
		String turnStr = null;
		if(getPrevSegment() != null){
			int turn = Angle.getTurn(getPrevSegment().getAngle(), getAngle());
			if(turn == Angle.CLOCKWISE){
				turnStr = "right";
			}else{
				turnStr = "left";
			}
		}
		return turnStr;
	}

	public Coordinate[] getCoordinateSequence(){
		Coordinate[] coords = null;
		if(edge != null){
			coords = edge.getCoordinates();
		}
		return coords;
	}

	public RouteSegment getNextSegment(){
		return nextSegment;
	}

	void setNextSegment(RouteSegment nextSegment){
		this.nextSegment = nextSegment;
	}

	public RouteSegment getPrevSegment(){
		return prevSegment;
	}

	void setPrevSegment(RouteSegment prevSegment){
		this.prevSegment = prevSegment;
	}

	void orderPoints(){
		Point startPt = edge.getStartPoint();
		Point endPt = edge.getEndPoint();
		Geometry intersection = null;
		if(nextSegment != null){
			intersection = nextSegment.getEdge().intersection(edge);
			if(!endPt.equals(intersection)){
				edge = edge.reverse();
			}
		}else if(prevSegment != null){
			intersection = prevSegment.getEdge().intersection(edge);
			if(!startPt.equals(prevSegment.getEdge().intersection(edge))){
				edge = edge.reverse();
			}
		}
	}

	@Override
	public String toString() {
		return "ID:" + id + ", Street:" + street + ", Source:" + source + ", Target:" + target;
	}

	@Override
	public boolean equals(Object obj) {
		return ((RouteSegment)obj).source == source && ((RouteSegment)obj).target == target;
	}
}
