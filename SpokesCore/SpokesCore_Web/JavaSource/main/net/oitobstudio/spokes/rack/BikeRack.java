package net.oitobstudio.spokes.rack;

import net.oitobstudio.spokes.MissingInputException;
import net.oitobstudio.spokes.PointOutOfBoundsException;
import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.geometry.BoundingBox;
import net.oitobstudio.spokes.geometry.GeometryUtils;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Point;

public class BikeRack {
	private long id;
	private Character rackType;
	private String address;
	private String rackCoordinate;
	private Point rackPoint;
	private int numberOfThefts;

	public BikeRack() {}
	
	public BikeRack(long id){
		this.id = id;
	}

	public BikeRack(String rackCoordinate, String address) {
		this.rackCoordinate = rackCoordinate;
		this.address = address;
	}

	public long getId() {
		return id;
	}

	public Character getRackType() {
		return rackType;
	}

	public String getAddress(){
		return address;
	}

	public String getRackCoordinate() {
		if(rackPoint != null){
			rackCoordinate = rackPoint.getCoordinate().x + "," + rackPoint.getCoordinate().y;
		}
		return rackCoordinate;
	}

	void makeRackPoint(GeometryFactory geometryFactory, BoundingBox bBox) throws SpokesException{
		Coordinate rackCoord = GeometryUtils.parseCoordinate(rackCoordinate);
		if(rackCoord == null){
			throw new MissingInputException("The required input for adding the rack is missing.  Please try again.");
		}else if(!BoundingBox.isPointInBoundingBox(geometryFactory, rackCoord, bBox)){
			throw new PointOutOfBoundsException("Point outside of bounding coordinates " + rackCoord, 
				"The location of the bike rack seems to be outside of city limits.");
		}
		rackPoint = geometryFactory.createPoint(GeometryUtils.parseCoordinate(getRackCoordinate()));
	}

	public int getNumberOfThefts(){
		return numberOfThefts;
	}

	@Override
	public String toString() {
		return "ID:" + id + ", RackType:" + rackType + ", RackPoint:" + rackPoint;
	}

	@Override
	public boolean equals(Object obj) {
		return id == ((BikeRack)obj).id;
	}
}