package net.oitobstudio.spokes.theft;

import java.util.Date;

import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.SpokesFault;
import net.oitobstudio.spokes.MissingInputException;
import net.oitobstudio.spokes.PointOutOfBoundsException;
import net.oitobstudio.spokes.geometry.BoundingBox;
import net.oitobstudio.spokes.geometry.GeometryUtils;
import net.oitobstudio.spokes.rack.BikeRack;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.Point;
import com.vividsolutions.jts.geom.GeometryFactory;

public class BikeTheft {
	private long id;
	private String comments;
	private BikeRack bikeRack;
	private Point theftPoint;
	private String theftCoordinate;
	private Date theftDate;
	private SpokesFault bikeTheftFault;

	public BikeTheft() {}
	
	public BikeTheft(Long bikeRackId, String theftCoordinate, String comments, Date theftDate) {
		if(bikeRackId != null){
			this.bikeRack = new BikeRack(bikeRackId);
		}
		this.theftCoordinate = theftCoordinate;
		this.comments = comments;
		this.theftDate = theftDate;
	}

	public long getId() {
		return id;
	}

	public String getComments() {
		return comments;
	}

	public BikeRack getBikeRack() {
		return bikeRack;
	}

	public String getTheftCoordinate() {
		if(theftPoint != null){
			theftCoordinate = theftPoint.getCoordinate().x + "," + theftPoint.getCoordinate().y;
		}
		return theftCoordinate;
	}

	public Date getTheftDate(){
		return theftDate;
	}

	void makeTheftPoint(GeometryFactory geometryFactory, BoundingBox bBox) throws SpokesException{
		Coordinate theftCoord = GeometryUtils.parseCoordinate(theftCoordinate);
		if(theftCoord == null){
			throw new MissingInputException("The required input for reporting the theft is missing.  Please try again.");
		}else if(!BoundingBox.isPointInBoundingBox(geometryFactory, theftCoord, bBox)){
			throw new PointOutOfBoundsException("Point outside of bounding coordinates " + theftCoord, 
				"The location of the reported bike theft seems to be outside of city limits.");
		}
		theftPoint = geometryFactory.createPoint(GeometryUtils.parseCoordinate(theftCoordinate));
	}

	@Override
	public String toString() {
		return "ID:" + id + ", Comments:" + comments + ", TheftPoint:" + theftPoint + ", TheftDate:" + theftDate;
	}

	@Override
	public boolean equals(Object obj) {
		return id == ((BikeTheft)obj).id;
	}
}