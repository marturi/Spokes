package net.oitobstudio.spokes.shop;

import com.vividsolutions.jts.geom.Point;

public class BikeShop {
	private long id;
	private Character hasRentals;
	private String shopName;
	private String streetAddress;
	private String borough;
	private String phoneNumber;
	private Point shopPoint;

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