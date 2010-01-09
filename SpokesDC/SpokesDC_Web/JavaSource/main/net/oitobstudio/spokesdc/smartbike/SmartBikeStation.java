package net.oitobstudio.spokesdc.smartbike;

import com.vividsolutions.jts.geom.Point;

public class SmartBikeStation {
	private long id;
	private String stationName;
	private Integer capacity;
	private String address;
	private Point stationPoint;
	private String quadrant;

	public SmartBikeStation() {}
	
	public SmartBikeStation(long id){
		this.id = id;
	}

	public long getId() {
		return id;
	}

	public String getStationName() {
		return stationName;
	}

	public String getAddress(){
		return address;
	}

	public String getStationCoordinate() {
		String stationCoordinate = null;
		if(stationPoint != null){
			stationCoordinate = stationPoint.getCoordinate().x + "," + stationPoint.getCoordinate().y;
		}
		return stationCoordinate;
	}

	public Integer getCapacity(){
		return capacity;
	}

	public String getQuadrant() {
		return quadrant;
	}

	@Override
	public String toString() {
		return "ID:" + id + ", StationName:" + stationName + ", StationPoint:" + stationPoint;
	}

	@Override
	public boolean equals(Object obj) {
		return id == ((SmartBikeStation)obj).id;
	}
}