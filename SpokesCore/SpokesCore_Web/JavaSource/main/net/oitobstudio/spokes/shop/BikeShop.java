package net.oitobstudio.spokes.shop;

import net.oitobstudio.spokes.MissingInputException;
import net.oitobstudio.spokes.PointOutOfBoundsException;
import net.oitobstudio.spokes.SpokesException;
import net.oitobstudio.spokes.geometry.BoundingBox;
import net.oitobstudio.spokes.geometry.GeometryUtils;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Point;

public class BikeShop {
	private long id;
	private Character hasRentals;
	private String shopName;
	private String streetAddress;
	private String borough;
	private String phoneNumber;
	private Point shopPoint;
	private String shopCoordinate;

	public BikeShop() {
	}

	public BikeShop(String shopName, 
			String streetAddress, 
			String phoneNumber, 
			String shopCoordinate, 
			Character hasRentals){
		this.shopName = shopName;
		this.streetAddress = streetAddress;
		this.phoneNumber = phoneNumber;
		this.shopCoordinate = shopCoordinate;
		this.hasRentals = hasRentals;
	}

	public long getId() {
		return id;
	}

	public char getHasRentals(){
		return hasRentals;
	}

	public String getShopName() {
		return shopName;
	}

	public String getStreetAddress() {
		return streetAddress;
	}

	public String getPhoneNumber(){
		return phoneNumber;
	}

	public String getBorough() {
		return borough;
	}

	public Point getShopPoint() {
		return shopPoint;
	}

	public String getShopCoordinate(){
		String shopCoordinate = null;
		if(shopPoint != null){
			shopCoordinate = shopPoint.getCoordinate().x + "," + shopPoint.getCoordinate().y;
		}
		return shopCoordinate;
	}

	void makeShopPoint(GeometryFactory geometryFactory, BoundingBox bBox) throws SpokesException{
		Coordinate shopCoord = GeometryUtils.parseCoordinate(shopCoordinate);
		if(shopCoord == null){
			throw new MissingInputException("The required input for adding the shop is missing.  Please try again.");
		}else if(!BoundingBox.isPointInBoundingBox(geometryFactory, shopCoord, bBox)){
			throw new PointOutOfBoundsException("Point outside of bounding coordinates " + shopCoord, 
				"The location of the bike shop seems to be outside of city limits.");
		}
		shopPoint = geometryFactory.createPoint(shopCoord);
	}

	@Override
	public String toString() {
		return "Id:" + id + ", HasRentals:" + hasRentals + ", ShopName:" + 
			shopName + ", StreetAddress:" + streetAddress + ", Borough" + ", ShopPoint:" + shopPoint;
	}

	@Override
	public boolean equals(Object obj) {
		return id == ((BikeShop)obj).id;
	}
}